import XCTest
@testable import Keanu

final class MatrixInitTests: XCTestCase {
    // MARK: Initializers
    internal func helperInitSingle<T: Equatable>(
        _ matrix: Matrix<T>, rows numRows: Int, columns numCols: Int, value: T
    ) {
        XCTAssertEqual(matrix.storage.count, numRows * numCols)
        XCTAssertEqual(matrix.count, matrix.storage.count)
        XCTAssert(matrix.allSatisfy { value == $0 })
    }

    func testRepeatingInit() {
        let numRows = 2
        let numCols = 7
        let value = "foo"
        let matrix = Matrix<String>(rows: numRows, columns: numCols, initialValue: value)
        helperInitSingle(matrix, rows: numRows, columns: numCols, value: value)
    }

    func testZeroInit() {
        let numRows = 2
        let numCols = 7
        let matrix = Matrix<Int>(rows: numRows, columns: numCols)
        helperInitSingle(matrix, rows: numRows, columns: numCols, value: 0)
    }

    func testNestedArrayInit() {
        let matrix = Matrix([[0, 1, 2], [3, 4, 5]])
        XCTAssertEqual(matrix.storage, [0, 1, 2, 3, 4, 5])
        XCTAssertEqual(matrix.rowCount, 2)
        XCTAssertEqual(matrix.columnCount, 3)
    }

    func testTransposeArrayInitColumnMajor() {
        let matrix = Matrix(
            [[2, 4, 6], [8, 10, 12]],
            sourceOrder: .rowMajor,
            order: .columnMajor
        )
        XCTAssertEqual(matrix.storage, [2, 8, 4, 10, 6, 12])
        XCTAssertEqual(matrix.rowCount, 2)
        XCTAssertEqual(matrix.columnCount, 3)
    }

    func testTransposeArrayInitRowMajor() {
        let matrix = Matrix(
            [[1, 2, 3], [2, 4, 6]],
            sourceOrder: .columnMajor,
            order: .rowMajor
        )
        XCTAssertEqual(matrix.storage, [1, 2, 3, 2, 4, 6])
        XCTAssertEqual(matrix.rowCount, 3)
        XCTAssertEqual(matrix.columnCount, 2)
    }

    func testArrayLiteral() {
        let matrix = [[1, 2], [3, 4], [5, 6]] as Matrix
        XCTAssertEqual(matrix.storage, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(matrix.rowCount, 3)
        XCTAssertEqual(matrix.columnCount, 2)
    }

    // MARK: Aggregate Access

    func testEquality() {
    }

    // MARK: Element Access

    func testIndexFor() {
        let matrix = [[1, 2], [3, 4], [5, 6]] as Matrix
        XCTAssertEqual(matrix.indexFor(row: 0, column: 0), 0)
    }
}
