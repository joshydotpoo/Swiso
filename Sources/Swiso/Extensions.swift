//
//  Swing Extensions
//  
//
//  Created by joshydotpoo on 3/11/24.
//  These were from several extensions from stack overflow, cant find the posts now.

import Foundation

extension StringProtocol {
    subscript(_ offset: Int) -> Element {
        self[index(startIndex,offsetBy: offset)]
    }
    subscript(_ range: Range<Int>) -> SubSequence {
        prefix(range.lowerBound+range.count).suffix(range.count)
    }
    subscript(_ range: ClosedRange<Int>) -> SubSequence {
        prefix(range.lowerBound+range.count).suffix(range.count)
    }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence {
        prefix(range.upperBound.advanced(by: 1))
    }
    subscript(_ range: PartialRangeUpTo<Int>)    -> SubSequence {
        prefix(range.upperBound )
    }
    subscript(_ range: PartialRangeFrom<Int>)    -> SubSequence {
        suffix(Swift.max(0, count-range.lowerBound))
    }
}

extension ContiguousBytes {
    func object<T>() -> T {
        withUnsafeBytes { $0.load(as: T.self) }
    }
}

extension Data {
    func subdata<R: RangeExpression>(in range: R) -> Self where R.Bound == Index {
        subdata(in: range.relative(to: self) )
    }
    func object<T>(at offset: Int) -> T {
        subdata(in: offset...).object()
    }
}
extension Sequence where Element == UInt8  {
    var data: Data { .init(self) }
}
extension Collection where Element == UInt8, Index == Int {
    func object<T>(at offset: Int = 0) -> T {
        data.object(at: offset)
    }
}

extension Dictionary {
    init(keys: [Key], values: [Value]) {
        self.init()
        
        for (key, value) in zip(keys, values) {
            self[key] = value
        }
    }
}
