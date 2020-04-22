import XCTest

@testable import Keanu

final class MatrixStringInitTests: XCTestCase {
    func testRepeatingInit() {
        let numRows = 2
        let numCols = 7
        let value = "foo"
        let matrix = Matrix<String>(rows: numRows, columns: numCols, initialValue: value)
        XCTAssertEqual(matrix.count, numCols * numRows)
        XCTAssertEqual(matrix.rowCount, numRows)
        XCTAssertEqual(matrix.columnCount, numCols)
        XCTAssert(matrix.allSatisfy { value == $0 })
    }
}
