import XCTest

@testable import Keanu

fileprivate typealias Element = Int

final class MatrixEqualityTests: XCTestCase {
    func testEmptyEqual() {
        let m1 = [[]] as Matrix<Element>
        let m2 = [[]] as Matrix<Element>
        XCTAssertEqual(m1, m2)
    }

    func testSingleEqual() {
        let m1 = [[1]] as Matrix<Element>
        let m2 = [[1]] as Matrix<Element>
        XCTAssertEqual(m1, m2)
    }

    func testNormalEqual() {
        let m1 = [[1, 2, 3], [4, 5, 6]] as Matrix<Element>
        let m2 = [[1, 2, 3], [4, 5, 6]] as Matrix<Element>
        XCTAssertEqual(m1, m2)
    }

    func testSameSizeNotEqual() {
        let m1 = [[1, 2, 3], [4, 5, 6]] as Matrix<Element>
        let m2 = [[4, 5, 6], [1, 2, 3]] as Matrix<Element>
        XCTAssertNotEqual(m1, m2)
    }

    func testSameCountNotEqual() {
        let m1 = [[1, 2, 3, 4, 5, 6]] as Matrix<Element>
        let m2 = [[1, 2, 3], [4, 5, 6]] as Matrix<Element>
        XCTAssertNotEqual(m1, m2)
    }

    func testDifferentCountNotEqual() {
        let m1 = [[]] as Matrix<Element>
        let m2 = [[1]] as Matrix<Element>
        XCTAssertNotEqual(m1, m2)
    }

    func testDifferentOrderEqual() {
        let m1 = Matrix<Element>([[1, 2, 3], [4, 5, 6]], order: .rowMajor)
        let m2 = Matrix<Element>([[1, 2, 3], [4, 5, 6]], order: .columnMajor)
        XCTAssertEqual(m1, m2)
    }

    func testDifferentOrderNotEqual() {
        let m1 = Matrix<Element>([[4, 5, 6], [4, 5, 6]], order: .rowMajor)
        let m2 = Matrix<Element>([[1, 2, 3], [4, 5, 6]], order: .columnMajor)
        XCTAssertNotEqual(m1, m2)
    }

    func testTransposedNotEqual() {
        let m1 = Matrix<Element>([[1, 2, 3], [4, 5, 6]], sourceOrder: .rowMajor, order: .rowMajor)
        let m2 = Matrix<Element>(
            [[1, 2, 3], [4, 5, 6]],
            sourceOrder: .columnMajor,
            order: .columnMajor
        )
        XCTAssertNotEqual(m1, m2)
    }
}

final class MatrixViewEqualityTests: XCTestCase {
    func testRowIsEqual() {
        let m = [[1, 2, 3], [4, 5, 6], [1, 2, 3]] as Matrix<Element>
        XCTAssertEqual(m.row(0), m.row(2))
    }

    func testRowIsNotEqual() {
        let m = [[1, 2, 3], [4, 5, 6], [1, 2, 3]] as Matrix<Element>
        XCTAssertNotEqual(m.row(0), m.row(1))
    }

    func testColumnIsEqual() {
        let m = [[1, 2, 1], [3, 5, 3], [1, 2, 1]] as Matrix<Element>
        XCTAssertEqual(m.column(0), m.column(2))
    }

    func testColumnIsNotEqual() {
        let m = [[1, 2, 1], [3, 5, 3], [1, 2, 1]] as Matrix<Element>
        XCTAssertNotEqual(m.column(0), m.column(1))
    }
}
