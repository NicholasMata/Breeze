import XCTest
@testable import Breeze

final class BreezeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Breeze().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
