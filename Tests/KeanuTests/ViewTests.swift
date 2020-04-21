import XCTest

@testable import Keanu

class ViewTestsCommon: XCTestCase {
    typealias Element = Int
    var matrix: Matrix<Element> = [[1, 2, 3], [4, 5, 6]]
}

final class RowViewTests: ViewTestsCommon {
    func view(_ index: Int) -> Matrix<Element>.RowView {
        return matrix.row(index)
    }

    func maxIndex() -> Int {
        return matrix.rowCount
    }

    func testViewAccess() {
        let maxIndex = self.maxIndex()
        for index in 0..<maxIndex {
            let view = self.view(index)
            XCTAssertEqual(view.matrix, matrix)
        }
    }
}

final class ColumnViewTests: ViewTestsCommon {
    func view(_ index: Int) -> Matrix<Element>.ColumnView {
        return matrix.column(index)
    }

    func maxIndex() -> Int {
        return matrix.columnCount
    }

    func testViewAccess() {
        let maxIndex = self.maxIndex()
        for index in 0..<maxIndex {
            let view = self.view(index)
            XCTAssertEqual(view.matrix, matrix)
        }
    }

}
