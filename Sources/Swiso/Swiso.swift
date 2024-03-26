//  Swiso.swift
//  Swiso
//
//  Created by joshydotpoo
//  Definitions and Description:
//      - ISO 8211 File Format: Information technology — Specification for a data descriptive file for information interchange
//      - The available resources online are awful, the ISO/IEC 8211 file format is old, and apparently the publications cost money.
//      - There were a few resources, linked below that were semi-useful. The GDAL had an actual implemenatation, but it's old code and in C++, so not a lot of translation to Swift.
//      - There's a lot of improvements that could be made, this code isn't optimized and I'm still not sure how to correctly implement the bitstring...so it just gets converted to ascii at the moment. Also, there may be a bug with the multi-dimensional formats (subfields that have a *). Found at least one instance where there weren't enough bytes to fill both columns equally. 
//  References:
//      - https://iho.int/uploads/user/Services%20and%20Standards/S-100WG/S-100WG7/S100WG7-4.16_2022_EN_ISO_IEC8211_Summary.pdf
//      - https://github.com/OSGeo/gdal/tree/master/frmts/iso8211
//      - https://scholarworks.calstate.edu/downloads/2r36v2640
import Foundation
import Tree

public struct Swiso {
    
    let data:Data
    private(set) var Records:[Record] = []
    
    private(set) var FieldAreaStructure:Node<Field>? 
    
    public init(_ data:Data, using FieldAreaStructure:Node<Field>? = nil) throws {
        self.data = data
        self.FieldAreaStructure = FieldAreaStructure
        try processRecord(0)
    }
    
    private mutating func processRecord(_ offset:Int) throws {
        if(offset < self.data.endIndex) {
            let recordData = self.data.subdata(in: self.data.startIndex + offset..<self.data.endIndex)

            var record:Record
            let recordType = Swiso.GetRecordType(recordData: recordData)
            
            if(recordType == RecordType.DataDescriptiveRecord) {
                record = SwisoDDR(recordData)
                self.FieldAreaStructure = record.fieldarea!.structure
            } else if(recordType == RecordType.DataRecord && self.FieldAreaStructure != nil) {
                record = SwisoDR(recordData, fieldStructure: self.FieldAreaStructure!)
            } else if(recordType == RecordType.DataRecord && self.FieldAreaStructure == nil) {
                throw FormattingError("Given Data Record with no Data Descriptive Record")
            } else {
                throw FormattingError("Format violation in leader")
            }
            
            self.Records.append(record)
            try processRecord(offset + record.leader!.recordLength)
        }
    }
    
    public static func GetRecordType(recordData:Data) -> RecordType {
        let recordIndicator = recordData.subdata(in: recordData.startIndex+6...recordData.startIndex + 6).object() as UInt8
        return RecordType(rawValue: recordIndicator)!
    }
    
    public func getRecords() -> [Record] {
        return Records
    }
    
    
    
}
