import XCTest
@testable import Keanu

final class ElementAccessTests: XCTestCase {
    func matrix<T: Numeric>(order: Matrix<T>.Order = .rowMajor) -> Matrix<T> {
        return Matrix([[1, 3, 5], [2, 4, 6]], order: order)
    }
    
    func testGetElementRowMajor() {
        let m: Matrix<Int> = matrix(order: .rowMajor)
        var expected = [1, 3, 5, 2, 4, 6].makeIterator()
        for row in 0..<m.rowCount {
            for column in 0..<m.columnCount {
                XCTAssertEqual(m.getElement(row: row, column: column), expected.next()!)
            }
        }
    }
    
    func testGetElementColumnMajor() {
        let m: Matrix<Int> = matrix(order: .columnMajor)
        var expected = [1, 3, 5, 2, 4, 6].makeIterator()
        for row in 0..<m.rowCount {
            for column in 0..<m.columnCount {
                XCTAssertEqual(m.getElement(row: row, column: column), expected.next()!)
            }
        }
    }
    
    func testIteratorRowMajor() {
        let m: Matrix<Int> = matrix(order: .rowMajor)
        let expected = [1, 3, 5, 2, 4, 6]
        for (actual, expected) in zip(m, expected) {
            XCTAssertEqual(actual, expected)
        }
    }
    
    func testIteratorColumnMajor() {
        let m: Matrix<Int> = matrix(order: .columnMajor)
        let expected = [1, 2, 3, 4, 5, 6]
        for (actual, expected) in zip(m, expected) {
            XCTAssertEqual(actual, expected)
        }
    }

}
