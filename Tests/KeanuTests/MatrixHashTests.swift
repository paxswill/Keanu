import XCTest
@testable import Keanu

fileprivate func hashOf<T: Hashable>(_ value: T) -> Int {
    var hasher = Hasher()
    hasher.combine(value)
    return hasher.finalize()
}

final class MatrixHashTests: XCTestCase {
    typealias Element = Int

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
