import XCTest
@testable import Keanu

final class MatrixEqualityTests: XCTestCase {
    typealias Element = Int

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
