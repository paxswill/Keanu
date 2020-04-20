import XCTest

@testable import Keanu

// As an overall note, it's not really possible to test precondition()/assert(),
// especially cross-platform so I'm just not.
// *If* I was to try, the best approach seems to be to run a single test in
// another process and check the return status from there.

// TODO: Convert to template
// At some point in the future, convert this to use a templating system so that
// instead of copy-pasting everything I can just run a template processor, that
// is ideally integrated into the SwiftPM process.

final class MatrixDotProduct: XCTestCase {

    func testDotSingle() {
        let lhs = [[1]] as Matrix
        let rhs = [[10]] as Matrix
        let dot = lhs.dot(rhs)
        XCTAssertEqual(dot, 10)
    }

    func testDotThree() {
        let rhs = [[1, 2, 3]] as Matrix
        let lhs = [[4, 5, 6]] as Matrix
        let dot = lhs.dot(rhs)
        XCTAssertEqual(dot, 32)
    }

    func testRowColumnVectors() {
        let lhs = [[1], [2], [3]] as Matrix
        let rhs = [[4, 5, 6]] as Matrix
        let dot = lhs.dot(rhs)
        XCTAssertEqual(dot, 32)
    }

    func testRowViewColumn() {
        let lhs = [[1], [2], [3]] as Matrix
        let rhs = [[4, 5, 6]] as Matrix
        let dot = lhs.dot(rhs.row(0))
        XCTAssertEqual(dot, 32)
    }

    func testMatrixArray() {
        let lhs = [[1], [2], [3]] as Matrix
        let rhs = [4, 5, 6]
        let dot = lhs.dot(rhs)
        XCTAssertEqual(dot, 32)
    }
}

final class MatrixViewDotProduct: XCTestCase {

    func testDotSingleRow() {
        let lhs = [[1]] as Matrix
        let rhs = [[10]] as Matrix
        let dot = lhs.row(0).dot(rhs.row(0))
        XCTAssertEqual(dot, 10)
    }

    func testDotSingleColumn() {
        let lhs = [[1]] as Matrix
        let rhs = [[10]] as Matrix
        let dot = lhs.column(0).dot(rhs.column(0))
        XCTAssertEqual(dot, 10)
    }

    func testDotSingleRowColumn() {
        let lhs = [[1]] as Matrix
        let rhs = [[10]] as Matrix
        let dot = lhs.row(0).dot(rhs.column(0))
        XCTAssertEqual(dot, 10)
    }

    func testDotThreeRow() {
        let rhs = [[1, 2, 3]] as Matrix
        let lhs = [[4, 5, 6]] as Matrix
        let dot = lhs.row(0).dot(rhs.row(0))
        XCTAssertEqual(dot, 32)
    }

    func testDotThreeColumn() {
        let rhs = [[1], [2], [3]] as Matrix
        let lhs = [[4], [5], [6]] as Matrix
        let dot = lhs.column(0).dot(rhs.column(0))
        XCTAssertEqual(dot, 32)
    }

    func testDotThreeRowColumn() {
        let lhs = [[1, 2, 3]] as Matrix
        let rhs = [[4], [5], [6]] as Matrix
        let dot = lhs.row(0).dot(rhs.column(0))
        XCTAssertEqual(dot, 32)
    }
}
