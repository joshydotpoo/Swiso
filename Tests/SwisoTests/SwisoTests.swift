import XCTest
@testable import Swiso
import Foundation

final class SwisoTests: XCTestCase {
    func testExample() throws {
        do {
            var url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            url = url.appendingPathComponent("playground/Github Contributions/Swiso/Tests/SwisoTests/US4AK6AT.000")
            let data = try Data(contentsOf: url)
            let swiso = try Swiso(data)
            let a = swiso.Records[0].fieldarea as! SwisoDDRFieldArea
            for a in a.structure.depthFirst {
                print(a.element.)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
