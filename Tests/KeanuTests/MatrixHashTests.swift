import XCTest
@testable import Keanu

fileprivate func hashOf<T: Hashable>(_ value: T) -> Int {
    var hasher = Hasher()
    hasher.combine(value)
    return hasher.finalize()
}

fileprivate typealias Element = Int

final class MatrixHashTests: XCTestCase {
    func testEmptyHash() {
        let m1 = [[]] as Matrix<Element>
        let m2 = [[]] as Matrix<Element>
        XCTAssertEqual(hashOf(m1), hashOf(m2))
    }

    func testDifferentSizes() {
        let m1 = [[1, 2], [3, 4], [5, 6]] as Matrix<Element>
        let m2 = [[1, 2, 3], [4, 5, 6]] as Matrix<Element>
        XCTAssertNotEqual(hashOf(m1), hashOf(m2))
    }

    func testDifferentOrderEqual() {
        let m1 = Matrix<Element>([[1, 2, 3], [4, 5, 6]], order: .rowMajor)
        let m2 = Matrix<Element>([[1, 2, 3], [4, 5, 6]], order: .columnMajor)
        XCTAssertEqual(hashOf(m1), hashOf(m2))
    }

    func testDifferentOrderNotEqual() {
        let m1 = Matrix<Element>([[4, 5, 6], [4, 5, 6]], order: .rowMajor)
        let m2 = Matrix<Element>([[1, 2, 3], [4, 5, 6]], order: .columnMajor)
        XCTAssertNotEqual(hashOf(m1), hashOf(m2))
    }

    func testSingleEqual() {
        let m1 = [[1]] as Matrix<Element>
        let m2 = [[1]] as Matrix<Element>
        XCTAssertEqual(m1, m2)
    }

    func testTransposedNotEqual() {
        let m1 = Matrix<Element>([[1, 2, 3], [4, 5, 6]], sourceOrder: .rowMajor, order: .rowMajor)
        let m2 = Matrix<Element>(
            [[1, 2, 3], [4, 5, 6]],
            sourceOrder: .columnMajor,
            order: .columnMajor
        )
        XCTAssertNotEqual(hashOf(m1), hashOf(m2))
    }
}

final class MatrixViewHashTests: XCTestCase {
    func testRowHashEqual() {
        let m = [[1, 2, 3], [1, 2, 3]] as Matrix<Element>
        XCTAssertEqual(hashOf(m.row(0)), hashOf(m.row(1)))
    }

    func testRowHashNotEqual() {
        let m = [[1, 2, 3], [4, 5, 6]] as Matrix<Element>
        XCTAssertNotEqual(hashOf(m.row(0)), hashOf(m.row(1)))
    }

    func testColumnHashEqual() {
        let m = [[1, 2, 1], [3, 5, 3], [1, 2, 1]] as Matrix<Element>
        XCTAssertEqual(hashOf(m.column(0)), hashOf(m.column(2)))
    }

    func testColumnHashNotEqual() {
        let m = [[1, 2, 1], [3, 5, 3], [1, 2, 1]] as Matrix<Element>
        XCTAssertNotEqual(hashOf(m.column(0)), hashOf(m.column(1)))
    }

    // While we can't compare them to each other (at least not yet), row and
    // column views will hash to the same value if they have the same element
    // values.
    func testRowColumnHashEqual() {
        let size = 5
        let m = Matrix<Element>.identityMatrix(size: size)
        for index in 0..<size {
            XCTAssertEqual(hashOf(m.row(index)), hashOf(m.column(index)))
        }
    }
}
