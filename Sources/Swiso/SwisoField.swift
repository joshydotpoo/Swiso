//
//  SwisoField.swift
//  
//
//  Created by joshydotpoo on 3/12/24.
//

import Foundation

internal struct FieldMap {
    let tag:String // aka Field Name
    let length:Int
    let position:Int
    
    init(tag:String, length:Int, position:Int) {
        self.tag = tag
        self.length = length
        self.position = position
    }
}

public struct Field:Identifiable {
    public var id: String
    var tag: String?
    var name: String?
    
    // External File Title only applies to Field Control Field
    var externalFileTitle:String?
    
    // Field Controls
    var structure:DataStructureCode?
    var type:DataTypeCode?
    
    // Only applies to Data Descriptive Fields
    var arrayDescriptor:String? = nil
    var formatControls:String? = nil
    
    init(tag:String, name:String? = nil, externalFileTitle: String? = nil, structure: DataStructureCode? = nil, type: DataTypeCode? = nil, arrayDescriptor: String? = nil, formatControls: String? = nil) {
        self.id = tag
        self.tag = tag
        self.name = name
        self.externalFileTitle = externalFileTitle
        self.structure = structure
        self.type = type
        self.arrayDescriptor = arrayDescriptor
        self.formatControls = formatControls
    }
}
