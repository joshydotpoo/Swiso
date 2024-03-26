//
//  SwisoDDR.swift
//
//
//  Created by joshydotpoo on 3/9/24.
//

import Foundation
import Tree

public struct SwisoDDR:Record {
    public let recordType: RecordType = RecordType.DataDescriptiveRecord
    
    private(set) var data:Data

    public private(set) var leader: Leader?
    public private(set) var directory: Directory?
    public private(set) var fieldarea: FieldArea?
    
    
    
    init(_ data:Data) {
        self.data = data
        self.leader = SwisoDDRLeader(GetLeaderData())
        self.directory = Directory(GetDirectoryData(), entryMap: self.leader!.entryMap)
        self.fieldarea = SwisoDDRFieldArea(GetFieldAreaData(), entryMaps: self.directory!.fieldmaps)
    }
    
    private func GetLeaderData() -> Data {
        return self.data.subdata(in: 0..<24)
    }
    
    private func GetDirectoryData() -> Data {
        return self.data.subdata(in: 24..<self.leader!.fieldAreaAddress - 1)
    }
    
    private func GetFieldAreaData() -> Data {
        return self.data.subdata(in: self.leader!.fieldAreaAddress..<self.leader!.recordLength)
    }
}

public struct SwisoDDRLeader:Leader {
    public var recordLength: Int
    public var leaderIdentifier: String
    public var codeExtensionIndicator: String
    public var versionNumber: String
    public var fieldAreaAddress: Int
    public var entryMap: EntryMap
    
    var fieldControlSize:Int = 9
    
    init(_ data:Data) {
        self.recordLength = ByteArray.toInt(data[0..<5])
        self.leaderIdentifier = ByteArray.toString(data[6...6])
        self.codeExtensionIndicator = ByteArray.toString(data[7...7])
        self.versionNumber = ByteArray.toString(data[8...8])
        self.fieldAreaAddress = ByteArray.toInt(data[12..<17])
        self.entryMap = EntryMap(data.subdata(in: 20..<24))
    }
}

public struct SwisoDDRFieldArea:FieldArea {
    
    public private(set) var structure:Node<Field>
    
    init(_ data:Data, entryMaps:[FieldMap]) {
        let fieldData:[Data] = data.split(separator: FormatControls.FT.rawValue)
        
        let controlFieldData:Data = fieldData[0]
        self.structure = SwisoDDRFieldArea.buildTree(controlFieldData) // from ControlField
        
        var nodeIndex = 1
        for node:Node<Field> in structure.depthFirst {
            var field = fieldData[nodeIndex]
    
            node.element.structure = DataStructureCode(rawValue: field.popFirst()!)
            node.element.type = DataTypeCode(rawValue: field.popFirst()!)
            
        
            let otherAttributesRange = field.startIndex+7..<field.endIndex
            field = field.subdata(in: otherAttributesRange)
            let otherAttributes = field.split(separator: FormatControls.UT.rawValue)
            
            node.element.name = ByteArray.toString(otherAttributes[0])
            if(otherAttributes.count > 2) {
                node.element.arrayDescriptor = ByteArray.toString(otherAttributes[1])
                node.element.formatControls = ByteArray.toString(otherAttributes[2])
            } else {
                node.element.formatControls = ByteArray.toString(otherAttributes[1])
            }
            
            
            nodeIndex += 1
        }

        let xmlTree:XMLTree<Field> = XMLTree<Field>(
            root: self.structure,
            using: \Field.id,
            assigning: [
                "tag": \Field.tag,
                "name": \Field.name,
                "externalFileTitle": \Field.externalFileTitle,
                "dataStructure": \Field.structure?.description,
                "dataType": \Field.type?.description,
                "arrayDescriptor": \Field.arrayDescriptor,
                "formatControls": \Field.formatControls
            ]
        )
        xmlTree.save()
    }
    
    private static func buildTree(_ data:Data) -> Node<Field> {
        let subdata = data.subdata(in: data.startIndex+9..<data.endIndex)
        let fieldControlData = subdata.split(separator: FormatControls.UT.rawValue)
        
        let hasExternalTitle = fieldControlData.count > 1
        
        let tagpairData = fieldControlData[hasExternalTitle ? 1 : 0]
        
        var rootField = Field(tag: ByteArray.toString(tagpairData.subdata(in: tagpairData.startIndex..<tagpairData.startIndex+4)))

        if(hasExternalTitle) {
            rootField.externalFileTitle = ByteArray.toString(fieldControlData[0])
        }
        
        let root:Node<Field> = Node(rootField)
        var currentNode:Node<Field> = root
        var offset = 0
        while(offset < tagpairData.count) {
            let parentField:Field = Field(tag: ByteArray.toString(tagpairData.subdata(in:tagpairData.startIndex+offset..<tagpairData.startIndex+offset+4)))
            let childNode:Node<Field> = Node(Field(tag: ByteArray.toString(tagpairData.subdata(in: tagpairData.startIndex+offset+4..<tagpairData.startIndex+offset+8))))
            while(parentField.id != currentNode.id) {
                currentNode = currentNode.parent!
            }
            currentNode.append(child: childNode)
            currentNode = childNode
            offset += 8
        }
        return root
    }
}

