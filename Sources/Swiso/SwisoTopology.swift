//
//  SwisoTopology.swift
//
//
//  Created by joshydotpoo on 3/9/24.
//

import Foundation
import Tree
import Collections

public protocol Record {
    var recordType:RecordType {get}
    var leader:Leader? {get}
    var directory:Directory? {get}
    var fieldarea:FieldArea? {get}
}

public protocol Leader {
    var recordLength:Int {get}
    var leaderIdentifier:String {get}
    var fieldAreaAddress:Int {get}
    var entryMap:EntryMap {get}
    
}

public struct Directory {
    
    var fieldmaps:[FieldMap] = []
    
    init(_ data:Data, entryMap:EntryMap) {
        var offset = 0
        while(offset < data.count) {
            let entry = entryMap.getValues(data, offset: offset)
            self.fieldmaps.append(entry)
            offset += entryMap.totalSize
        }
    }
}

public protocol FieldArea {
    var structure:Node<Field> {get}
}

public struct EntryMap {
    private(set) var lengthSize: Int
    private(set) var positionSize: Int
    private(set) var tagSize:Int
    private(set) var totalSize:Int
    
    init(_ data:Data) {
        self.lengthSize = ByteArray.toInt(data[0...0])
        self.positionSize = ByteArray.toInt(data[1...1])
        self.tagSize = 4
        self.totalSize = self.lengthSize + self.positionSize + self.tagSize
    }
    
    func getValues(_ data:Data, offset:Int = 0) -> FieldMap {
        let tagRange = offset..<offset+self.tagSize
        let lengthRange = tagRange.upperBound..<tagRange.upperBound + self.lengthSize
        let positionRange = lengthRange.upperBound..<lengthRange.upperBound + self.positionSize
        return FieldMap(
            tag: ByteArray.toString(data[tagRange]),
            length: ByteArray.toInt(data[lengthRange]),
            position: ByteArray.toInt(data[positionRange])
        )
    }
}

public struct FormattingError:LocalizedError {
    let errorDescription: String
    
    init(_ errorDescription: String) {
        self.errorDescription = errorDescription
    }
}

