import XCTest

@testable import Keanu

final class CollectionArithmeticTests: XCTestCase {
    func testVectorVectorAddition() {
        let a = [1, 2, 3]
        let b = [4, 5, 6]
        let expected = [5, 7, 9]
        XCTAssertEqual(a .+ b, expected)
    }

    func testVectorScalarAddition() {
        let vector = [2, 4, 6]
        let scalar = 2
        let expected = [4, 6, 8]
        XCTAssertEqual(vector .+ scalar, expected)
        XCTAssertEqual(scalar .+ vector, expected)
    }

    func testVectorVectorSubtraction() {
        let a = [2, 4, 6]
        let b = [1, 3, 5]
        XCTAssertEqual(a .- b, [1, 1, 1])
    }

    func testVectorScalarSubtraction() {
        let vector = [2, 4, 6]
        let scalar = 1
        let expected = [1, 3, 5]
        XCTAssertEqual(vector .- scalar, expected)
    }
}

final class MatrixArithmeticTests: XCTestCase {
    func testMatrixMatrixAddition() {
        let a = [[1, 2], [3, 4]] as Matrix
        let b = [[5, 6], [7, 8]] as Matrix
        let expected = [[6, 8], [10, 12]] as Matrix
        XCTAssertEqual(a .+ b, expected)
    }

    func testMatrixScalarAddition() {
        let matrix = [[2, 4], [6, 8]] as Matrix
        let scalar = 1
        let expected = [[3, 5], [7, 9]] as Matrix
        XCTAssertEqual(matrix .+ scalar, expected)
        XCTAssertEqual(scalar .+ matrix, expected)
    }

    func testMatrixMatrixSubtraction() {
        let a = [[5, 6], [7, 8]] as Matrix
        let b = [[1, 2], [3, 4]] as Matrix
        let expected = [[4, 4], [4, 4]] as Matrix
        XCTAssertEqual(a .- b, expected)
    }

    func testMatrixScalarSubtraction() {
        let matrix = [[2, 4], [6, 8]] as Matrix
        let scalar = 1
        let expected = [[1, 3], [5, 7]] as Matrix
        XCTAssertEqual(matrix .- scalar, expected)
    }
}
