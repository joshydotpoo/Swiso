//
//  SwisoSubfield.swift
//
//
//  Created by joshydotpoo on 3/12/24.
//

import Foundation
import Collections
import Tree


public struct Subfield {
    private(set) var tag:String
    private(set) var type:SubfieldType
    private(set) var width:Int
    private(set) var value:Any
    
    
    static func GetAll(field: Field, data: Data) -> [Subfield] {
        var subfields:[Subfield] = []
        
        // 0001 fields have no array descriptor
        var arrayDescriptor = field.arrayDescriptor
        if(arrayDescriptor != nil) {
            // check if values are part of an array
            var isMultidimensional = false
            
            if(arrayDescriptor!.contains("*")) {
                isMultidimensional = true
                arrayDescriptor = String(arrayDescriptor!.dropFirst())
            }
            // get the subfield tags
            let subfieldTags = arrayDescriptor!.split(separator: "!")

            // assign each format control a type
            let formatControls = field.formatControls!.dropFirst().dropLast().split(separator: ",")
            let subfieldFormats:[SubfieldFormat] = formatControls.map({
                return SubfieldFormat(format: String($0)).reduce()
            }).flatMap{$0}
            
            // loop through data, assigning each subfieldtag the correct data
            // keep track of data thats left
            var unprocessedData = data
            var subfieldIndex = 0
            // not at the end of the data
            while(data.count > 1 && unprocessedData[0] as UInt8 != FormatControls.FT.rawValue) {
                let format = subfieldFormats[subfieldIndex]
                let tag = subfieldTags[subfieldIndex]
                // not variable width
                if(format.width != nil) {
                    let value = format.type.CastData(unprocessedData[..<format.width!])
                    let subfield = Subfield(tag: String(tag), type: format.type, width: format.width!, value: value)
                    print(subfield)
                    subfields.append(subfield)
                    unprocessedData = unprocessedData.subdata(in: format.width!..<unprocessedData.count)
                } else { // variable width
                    let utIndex = unprocessedData.firstIndex(of: FormatControls.UT.rawValue)!
                    let value = format.type.CastData(unprocessedData[..<utIndex])
                    let subfield = Subfield(tag: String(tag), type: format.type, width: -1, value: value)
                    print(subfield)
                    subfields.append(subfield)
                    unprocessedData = unprocessedData.subdata(in: utIndex+1..<unprocessedData.count)
                }
                subfieldIndex += 1
                if(isMultidimensional && subfieldIndex == subfieldFormats.count) {
                    subfieldIndex = 0
                }
            }
            
            
            if(isMultidimensional) {
                var subfieldsDictionary:[String:(type: SubfieldType, width:Int, values: [Any])] = [:]
                for subfield in subfields {
                    if var subfieldTuple = subfieldsDictionary[subfield.tag] {
                        var subfieldArray = subfieldTuple.values
                        subfieldArray.append(subfield.value)
                        subfieldTuple.values = subfieldArray
                        subfieldsDictionary[subfield.tag] = subfieldTuple
                    } else {
                        let subfieldTuple = (type: subfield.type, width: subfield.width, values: [subfield.value])
                        subfieldsDictionary[subfield.tag] = subfieldTuple
                    }
                }

                var index = 0
                subfields = subfieldTags.enumerated().map{(index, tagValue) in
                    if let subfieldTuple = subfieldsDictionary[String(tagValue)] {
                        return Subfield(tag: String(tagValue), type: subfieldTuple.type, width: subfieldTuple.width, value: subfieldTuple.values)
                    } else {
                        return Subfield(tag: String(tagValue), type: subfieldFormats[index].type, width: subfieldFormats[index].width ?? -1, value: [])
                    }
                }
            }
        }
        
        return subfields
    }
}

public struct SubfieldFormat {
    private(set) var type:SubfieldType
    private(set) var repeatCount:Int
    private(set) var width:Int? // will be nil if variable width
    
    
    init(format:String) {
        self.type = SubfieldType.GetType(format)!
        self.repeatCount = format.first!.wholeNumberValue ?? 1
        if(self.type.rawValue.range(of: "b") != nil) { // Is it a byte?
            self.width = format.last!.wholeNumberValue!
        } else if(self.type.rawValue.range(of: "B") != nil) { // Bitstring?
            let bitValue = Int(format.suffix(from: format.firstIndex(of: "(")!).dropFirst().dropLast())!
            self.width =  bitValue / 8
        } else if(format[format.count - 1] == ")"){ // Then it must be a string or real number (as a string)
            let byteValue = Int(format.suffix(from: format.firstIndex(of: "(")!).dropFirst().dropLast())!
            self.width = byteValue
        } else { // is a variable width such as 3A ( not A(8) )
            self.width = nil
        }
    }
    
    func reduce() -> [SubfieldFormat] {
        var reducedCopy = self
        reducedCopy.repeatCount = 1
        return [SubfieldFormat](repeating: reducedCopy, count: self.repeatCount)
    }
}

public enum SubfieldType:String, CaseIterable {
    case string = "A"
    case real = "R"
    case bitstring = "B"
    case uint8 = "b11"
    case uint16 = "b12"
    case uint32 = "b14"
    case int8 = "b21"
    case int16 = "b22"
    case int32 = "b24"
    case double = "b48"
    
    public func CastData(_ data:Data) -> Any {
        switch(self) {
            case .uint8: return data.object() as UInt8
            case .uint16: return data.object() as UInt16
            case .uint32: return data.object() as UInt32
            case .int8: return data.object() as Int8
            case .int16: return data.object() as Int16
            case .int32: return data.object() as Int32
            case .double: return data.object() as Double
            case .string: return ByteArray.toString(data)
            case .real: return Float(ByteArray.toString(data))!
            case .bitstring: return ByteArray.toBitString(data)
        }
    }
    
    public static func GetType(_ value:String) -> SubfieldType? {
        let types = SubfieldType.allCases
        for type in types {
            if((value.range(of: type.rawValue)) != nil) {
                return type
            }
        }
        return nil
    }
}
