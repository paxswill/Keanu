import XCTest
@testable import Keanu

final class IdentityMatrixTests: XCTestCase {
    func testIdentityMatrixInt0() {
        let m = Matrix<Int>.identityMatrix(size: 0)
        XCTAssert(m.isEmpty)
    }

    func testIdentityMatrixDouble0() {
        let m = Matrix<Double>.identityMatrix(size: 0)
        XCTAssert(m.isEmpty)
    }

    func testIdentityMatrixInt1() {
        let m = Matrix<Int>.identityMatrix(size: 1)
        XCTAssertEqual(m.scalar, Int(1))
    }

    func testIdentityMatrixDouble1() {
        let m = Matrix<Double>.identityMatrix(size: 1)
        XCTAssertEqual(m.scalar, Double(1))
    }

    // Putting the generic as the return value to satisfy the compiler.
    func commonMatrixTest<T: Numeric>(size: Int = 5) -> T {
        let m = Matrix<T>.identityMatrix(size: size)
        for row in 0..<size {
            for column in 0..<size {
                XCTAssertEqual(m[row, column], row == column ? T(exactly: 1) : T.zero)
            }
        }
        return T.zero
    }

    func testIdentityMatrixInt() {
        // And this dance with assigning to foo and then ignoring it is to make
        // the compiler warnings go away.
        let foo: Int = commonMatrixTest()
        _ = foo.description
    }

    func testIdentityMatrixDouble() {
        let foo: Double = commonMatrixTest()
        _ = foo.description
    }
}
