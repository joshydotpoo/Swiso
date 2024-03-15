# Swiso

***Swiso***  is a ISO/IEC 8211 file parser implemented in Swift.

## Installation

Use Swiso with the Swift Package Manager. To install it within another Swift package, add it as a dependency within your Package.swift manifest:
```swift
let package = Package(
    // . . .
    dependencies: [
        .package(url: "https://github.com/joshydotpoo/Swiso.git", branch: "main")
    ],
    // . . .
)
```

## Usage

Parsing the data:
```Swift
do {
  let data = Data(contentsOf: someURL)
  // Throws an error with invalid formatting.
  let swiso = try Swiso(data)
} catch {
  print(error.localizedDescription)
}
```

Getting the records:
```Swift
//...
let records = swiso.Records
for record in records {
  if(record.recordType == RecordType.DataDescriptiveRecord) {
    print("Data Descriptive Record")
  } else {
    print("Data Record")
  }
}
//...
```

Getting field data:
```Swift
//...
let fieldarea = record.fieldarea as! SwisoDDRFieldArea
// node to the root of the pre-traversal tree
let structure:Node<Field> = fieldarea.structure
for fieldNode in a.structure.depthFirst {
  print(fieldNode.element.name)
  print(fieldNode.element.arrayDescriptor)
  print(fieldNode.element.formatControls)
}
//...
```

Getting subfield data:
```Swift
//...
let fieldarea = record.fieldarea as! SwisoDRFieldArea
let subfields:OrderedDictionary<String, [Subfield]> = fieldarea.subfields
//...
```
