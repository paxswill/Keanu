/// A basic implementation of a matrix data type.
///
/// This implementation should be able to be used on all platforms Swift
/// supports.
public struct BasicMatrix<T>: MatrixProtocol {
    /// The type of elements contained within this matrix.
    public typealias Element = T

    /// A single-value type that can be used to access elements by index.
    public typealias Index = MatrixIndex

    /// The type of the views over individual rows of the matrix.
    public typealias RowView = BasicRowView<Self, Element>

    /// The type of the views over individual columns of the matrix.
    public typealias ColumnView = BasicColumnView<Self, Element>

    /// The number of rows in the matrix.
    public let rowCount: Int

    /// The number of columns in the matrix.
    public let columnCount: Int

    // This would normally be private, but needs to be internal to be usable
    // from inline.
    @usableFromInline internal var storage: [[Element]]

    /// Initialize a matrix with a single repeated value.
    public init(rows: Int, columns: Int, initialValue: Element) {
        rowCount = rows
        columnCount = columns
        storage = [[Element]]()
        for _ in 0..<rowCount {
            let row = [Element](repeating: initialValue, count: columnCount)
            storage.append(row)
        }
    }

    /// Initialize a matrix from a two-dimensional array of Elements.
    ///
    /// - Parameter elementArrays: A 2D-array of Elements. The inner arrays
    ///   *must* all have the same number of elements.
    public init(_ elementArrays: [[Element]]) {
        if elementArrays.isEmpty || elementArrays[0].isEmpty {
            rowCount = 0
            columnCount = 0
        } else {
            rowCount = elementArrays.count
            columnCount = elementArrays[0].count
        }
        storage = Array()
        for rowIndex in 0..<elementArrays.count {
            storage.append(Array(elementArrays[rowIndex]))
        }
    }

    /// Returns a `RowView` for the given row.
    public func row(_ rowIndex: Int) -> RowView {
        return RowView(self, index: rowIndex)
    }

    /// Returns a `ColumnView` for the given column.
    public func column(_ columnIndex: Int) -> ColumnView {
        return ColumnView(self, index: columnIndex)
    }

    /// Get an element at the given row and column.
    @inlinable public func getElement(row: Int, column: Int) -> Element {
        return storage[row][column]
    }

    /// Set an element at the given row and column.
    @inlinable mutating public func setElement(_ element: T, row: Int, column: Int) {
        storage[row][column] = element
    }
}

extension BasicMatrix: Equatable where Element: Equatable {}
extension BasicMatrix: Hashable where Element: Hashable {}
extension BasicMatrix: MatrixOperations where Element: Numeric {}
