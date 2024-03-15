//
//  SwisoConversions.swift
//
//
//  Created by joshydotpoo on 3/9/24.
//

import Foundation

internal struct ByteArray {
    
    static func toString(_ d:Data, encoding:String.Encoding = String.Encoding.ascii) -> String {
        return String(data: d, encoding: encoding)!
    }
    
    static func toInt(_ d:Data) -> Int {
        return Int(toString(d))!
    }
    
    static func toBitString(_ d:Data) -> String {
        return toString(d)
    }
}
