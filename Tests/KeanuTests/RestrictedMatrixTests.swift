import XCTest
@testable import Keanu

final class RestrictedMatrixTests: XCTestCase {
    typealias Element = Int

    func testIsEmpty1D() {
        let m = [] as Matrix<Element>
        XCTAssert(m.isEmpty)
    }

    func testIsEmpty2D() {
        let m = [[]] as Matrix<Element>
        XCTAssert(m.isEmpty)
    }

    func testIsNotEmpty() {
        let m = [[1]] as Matrix<Element>
        XCTAssertFalse(m.isEmpty)
    }

    func testIsEmptySquare() {
        let m = [[]] as Matrix<Element>
        XCTAssert(m.isSquare)
    }

    func testIsSquare() {
        let m = [[1, 2], [3, 4]] as Matrix<Element>
        XCTAssert(m.isSquare)
    }

    func testIsNotSquare() {
        let m = [[1], [2]] as Matrix<Element>
        XCTAssertFalse(m.isSquare)
    }

    func testIsRowVector() {
        let m = [[1, 2, 3]] as Matrix<Element>
        XCTAssert(m.isVector)
        XCTAssertEqual(m.vector, [1, 2, 3] as [Element])
    }

    func testIsColumnVector() {
        let m = [[1], [2], [3]] as Matrix<Element>
        XCTAssert(m.isVector)
        XCTAssertEqual(m.vector, [1, 2, 3] as [Element])
    }

    func testIsNotVector() {
        let m = [[1, 2], [3, 4]] as Matrix<Element>
        XCTAssertFalse(m.isVector)
        XCTAssertNil(m.vector)
    }

    func testIsScalar() {
        let m = [[1]] as Matrix<Element>
        XCTAssert(m.isScalar)
        XCTAssertEqual(m.scalar, 1 as Element)
    }

    func testIsNotScalar() {
        let m = [[1, 2, 3]] as Matrix<Element>
        XCTAssertFalse(m.isScalar)
        XCTAssertNil(m.scalar)
    }

}
