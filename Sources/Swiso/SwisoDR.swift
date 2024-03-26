//
//  SwisoDR.swift
//  
//
//  Created by joshydotpoo on 3/10/24.
//

import Foundation
import Tree
import Collections

public struct SwisoDR:Record {
    public let recordType: RecordType = RecordType.DataRecord

    public var leader: Leader?
    public var directory: Directory?
    public var fieldarea: FieldArea?
    
    private(set) var data:Data
    
    init(_ data:Data, fieldStructure:Node<Field>) {
        self.data = data
        self.leader = SwisoDRLeader(GetLeaderData())
        
        self.directory = Directory(
            GetDirectoryData(),
            entryMap: self.leader!.entryMap
        )
        
        self.fieldarea = SwisoDRFieldArea(subfieldData: GetSubfieldData(), structure: fieldStructure)
    }
    
    private func GetLeaderData() -> Data {
        return self.data.subdata(in:  0..<24)
    }
    
    private func GetDirectoryData() -> Data {
        return self.data.subdata(in: 24..<self.leader!.fieldAreaAddress - 1)
    }
    
    private func GetFieldAreaData() -> Data {
        return self.data.subdata(in: 
            self.leader!.fieldAreaAddress..<self.leader!.recordLength
        )
    }
    
    private func GetSubfieldData() -> OrderedDictionary<String, Data> {
        var dictionary:OrderedDictionary<String, Data> = [:]
        
        let start = self.leader!.fieldAreaAddress
        let fieldmaps = self.directory!.fieldmaps
        
        for fieldmap in fieldmaps {
            let tag = fieldmap.tag
            
            let subfieldStart = data.startIndex + start + fieldmap.position
            let subfieldEnd = subfieldStart + fieldmap.length
            let subfieldRange = subfieldStart ..< subfieldEnd
            let subfieldData = self.data.subdata(in: subfieldRange)
            dictionary[tag] = subfieldData
        }

        return dictionary
    }
}

public struct SwisoDRLeader:Leader {
    public var recordLength: Int
    public var leaderIdentifier: String
    public var fieldAreaAddress: Int
    public var entryMap: EntryMap
    
    var fieldControlSize:Int = 9
    
    init(_ data:Data) {
        self.recordLength = ByteArray.toInt(data[0..<5])
        self.leaderIdentifier = ByteArray.toString(data[6...6])
        self.fieldAreaAddress = ByteArray.toInt(data[12..<17])
        self.entryMap = EntryMap(data.subdata(in: 20..<24))
    }
}

public struct SwisoDRFieldArea: FieldArea {
    
    public var structure:Node<Field>
    private(set) var subfields:OrderedDictionary<String, [Subfield]> = [:]
    
    init(subfieldData:OrderedDictionary<String, Data>, structure:Node<Field>) {
        self.structure = structure
        
        for (tag, data) in subfieldData {
            let field = structure.node(identifiedBy: tag)!.element
            subfields[tag] = Subfield.GetAll(field: field, data: data)
        }

    }
}
