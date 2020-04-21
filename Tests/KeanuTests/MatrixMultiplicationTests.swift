import XCTest

@testable import Keanu

final class MatrixMultiplicationTests: XCTestCase {
    func testMultiply() {
        let a = [[2, 3], [-1, 4]] as Matrix
        let b = [[0, 5], [3, -4]] as Matrix
        let ab = [[9, -2], [12, -21]] as Matrix
        XCTAssertEqual(a ** b, ab)
    }
}
