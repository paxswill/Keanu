import XCTest
@testable import Keanu

// I tried arranging the common tests as protocols with default implementations
// provided by extensions, but XCTest discovery didn't find the common tests.
// On the other hand, using a class that skips the common definitions *does*
// work.
// I tested overriding defaultTestSuite (returning an empty test suite),
// setupWithErrors (skipping with XCTSkipIf), and overriding invokeTest (doing
// nothing), and the last provides the best experience in my opinion.
// overriding setUpWithErrors marked the extra tests as "skipped", and was the
// second best option. Overriding defaultTestSuite marked the common
// implementations as skipped, but still allowed them to be invoked directly,
// which would then fail. Overriding invokeTest makrs the base implementations
// as passed in all cases. Test invokation for the concrete cases was confirmed
// by setting a breakpoint in the common case and confirming it was hit.

class ElementAccessTestsCommon: XCTestCase {
    typealias Element = Int

    // MARK: Pseudo-properties

    func order() -> Order {
        fatalError()
    }

    func matrix() -> Matrix<Element> {
        return Matrix([[1, 3, 5], [2, 4, 6]], order: order())
    }

    func expectedOrder() -> [Element] {
        fatalError()
    }

    override func invokeTest() {
        if Self.self == ElementAccessTestsCommon.self {
            return
        } else {
            return super.invokeTest()
        }
    }

    // MARK: Common Tests

    var expectedRowMajor: [Element] = [1, 3, 5, 2, 4, 6]

    func testGetElement() {
        var expected = expectedRowMajor.makeIterator()
        let matrix = self.matrix()
        for rowIndex in 0..<matrix.rowCount {
            for columnIndex in 0..<matrix.columnCount {
                let element = matrix.getElement(row: rowIndex, column: columnIndex)
                XCTAssertEqual(element, expected.next())
            }
        }
    }

    func testGetSubscript() {
        var expected = expectedRowMajor.makeIterator()
        let matrix = self.matrix()
        for rowIndex in 0..<matrix.rowCount {
            for columnIndex in 0..<matrix.columnCount {
                XCTAssertEqual(matrix[rowIndex, columnIndex], expected.next())
            }
        }
    }

    func testSetElement() {
        let expected = expectedRowMajor.map { $0 * 2 }
        var expectedIterator = expected.makeIterator()
        var matrix = self.matrix()
        for rowIndex in 0..<matrix.rowCount {
            for columnIndex in 0..<matrix.columnCount {
                matrix.setElement(expectedIterator.next()!, row: rowIndex, column: columnIndex)
            }
        }
        expectedIterator = expected.makeIterator()
        for rowIndex in 0..<matrix.rowCount {
            for columnIndex in 0..<matrix.columnCount {
                XCTAssertEqual(
                    matrix.getElement(row: rowIndex, column: columnIndex),
                    expectedIterator.next()!
                )
            }
        }
    }

    func testSetSubscript() {
        let expected = expectedRowMajor.map { $0 * 2 }
        var expectedIterator = expected.makeIterator()
        var matrix = self.matrix()
        for rowIndex in 0..<matrix.rowCount {
            for columnIndex in 0..<matrix.columnCount {
                matrix[rowIndex, columnIndex] = expectedIterator.next()!
            }
        }
        expectedIterator = expected.makeIterator()
        for rowIndex in 0..<matrix.rowCount {
            for columnIndex in 0..<matrix.columnCount {
                XCTAssertEqual(
                    matrix.getElement(row: rowIndex, column: columnIndex),
                    expectedIterator.next()!
                )
            }
        }
    }

    func testIterator() {
        let matrix = self.matrix()
        let expected = self.expectedOrder()
        for (actual, expected) in zip(matrix, expected) {
            XCTAssertEqual(actual, expected)
        }
    }
}

final class RowMajorElementAccessTests: ElementAccessTestsCommon {
    override func order() -> Order { .rowMajor }
    override func expectedOrder() -> [ElementAccessTestsCommon.Element] {
        [1, 3, 5, 2, 4, 6]
    }
}

final class ColumnMajorElementAccessTests: ElementAccessTestsCommon {
    override func order() -> Order { .columnMajor }
    override func expectedOrder() -> [ElementAccessTestsCommon.Element] {
        [1, 2, 3, 4, 5, 6]
    }
}
