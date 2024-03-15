//
//  SwisoEnums.swift
//
//
//  Created by joshydotpoo on 3/9/24.
//
import Foundation

internal enum RecordType:UInt8 {
    
    case DataDescriptiveRecord = 0x4C
    case DataRecord = 0x44
}

enum DataStructureCode: UInt8, CustomStringConvertible {
    case linear = 49 // aka UInt8(ascii: "1")
    case multidimensional = 50 // aka UInt8(ascii: "2")
    case concatenated = 51 // aka UInt8(ascii: "3")
    
    var description: String {
        switch self {
            case .linear: "linear"
            case .multidimensional: "multidimensional"
            case .concatenated: "concatenated"
        }
    }
}

enum DataTypeCode: UInt8, CustomStringConvertible {
    case integer = 49 // aka UInt8(ascii: "1")
    case float = 50 // aka UInt8(ascii: "2")
    case mixed = 54 // aka UInt8(ascii: "6")
    
    var description: String {
        switch self {
            case .integer: "integer"
            case .float: "float"
            case .mixed: "mixed"
        }
    }
}

enum FormatControls:UInt8, CustomStringConvertible {
    case SPACE = 0x20
    case UT = 0x1F
    case FT = 0x1E
    
    var description: String {
        switch self {
            case .SPACE: " "
            case .UT: "0x1F"
            case .FT: "0x1E"
        }
    }
    
}
