/// A basic implementation of a matrix data type.
///
/// This implementation should be able to be used on all platforms Swift
/// supports.
public struct ContiguousMatrix<T>: MatrixProtocol, ContiguousMatrixProtocol {
    /// The type of elements contained within this matrix.
    public typealias Element = T

    /// A single-value type that can be used to access elements by index.
    public typealias Index = MatrixIndex

    /// The type of the views over individual rows of the matrix.
    public typealias RowView = BasicRowView<Self, Element>

    /// The type of the views over individual columns of the matrix.
    public typealias ColumnView = BasicColumnView<Self, Element>

    /// The number of rows in the matrix.
    public private(set) var rowCount: Int

    /// The number of columns in the matrix.
    public private(set) var columnCount: Int

    /// Whether this matrix is using a row-major or column-major representation
    /// internally.
    public let order: Order

    // This would normally be private, but needs to be internal to be usable
    // from inline.
    @usableFromInline internal var storage: ContiguousArray<Element>

    /// Initialize a matrix with a single repeated value.
    public init(rows: Int, columns: Int, initialValue: Element, order: Order = .rowMajor) {
        rowCount = rows
        columnCount = columns
        self.order = order
        storage = ContiguousArray(repeating: initialValue, count: rows * columns)
    }

    /// Initialize a matrix with a single repeated value.
    public init(rows: Int, columns: Int, initialValue: T) {
        // Have to explicitly put the default arguments in to avoid recursion
        self.init(rows: rows, columns: columns, initialValue: initialValue, order: .rowMajor)
    }

    /// Initialize a matrix from a two-dimensional array of Elements.
    ///
    /// - Parameters:
    ///     - elementArrays: A 2D-array of Elements. The inner arrays *must* all
    ///       have the same number of elements.
    ///     - sourceOrder: Declare whether `elementArrays` is a row-major or
    ///       column-major representation of a matrix.
    ///     - order: What the newly created matrix should use for storing the
    ///       elements.
    public init(
        _ elementArrays: [[Element]],
        sourceOrder: Order = .rowMajor,
        order: Order = .rowMajor
    ) {
        if elementArrays.isEmpty || elementArrays[0].isEmpty {
            rowCount = 0
            columnCount = 0
        } else {
            switch sourceOrder {
            case .rowMajor:
                rowCount = elementArrays.count
                columnCount = elementArrays[0].count
            case .columnMajor:
                rowCount = elementArrays[0].count
                columnCount = elementArrays.count
            }
        }
        storage = ContiguousArray()
        storage.reserveCapacity(rowCount * columnCount)
        self.order = order
        // NOTE: While `storage` has space *reserved* for the contents, it
        // doesn't have any actual data so we need to append everything in
        // the appropriate order (as opposed to just setting the proper
        // index if the array was initialized).
        if order == sourceOrder {
            storage.append(contentsOf: elementArrays.flatMap { $0 })
        } else {
            for sourceColumn in 0..<elementArrays[0].count {
                for sourceRow in 0..<elementArrays.count {
                    storage.append(elementArrays[sourceRow][sourceColumn])
                }
            }
        }
    }

    /// Initialize a matrix from a two-dimensional array of Elements.
    ///
    /// - Parameter elementArrays: A 2D-array of Elements. The inner arrays
    ///   *must* all have the same number of elements.
    public init(_ elementArrays: [[Element]]) {
        // Have to explicitly put the default arguments in to avoid recursion
        self.init(elementArrays, sourceOrder: .rowMajor, order: .rowMajor)
    }

    /// Returns a `RowView` for the given row.
    public func row(_ rowIndex: Int) -> RowView {
        return RowView(self, index: rowIndex)
    }

    /// Returns a `ColumnView` for the given column.
    public func column(_ columnIndex: Int) -> ColumnView {
        return ColumnView(self, index: columnIndex)
    }

    /// Internal helper the calculates the proper index in the backing store for
    /// the given row and column.
    @inlinable internal func indexFor(row: Int, column: Int) -> Int {
        switch order {
        case .rowMajor:
            return column + row * columnCount
        case .columnMajor:
            return row + column * rowCount
        }
    }

    /// Get an element at the given row and column.
    @inlinable public func getElement(row: Int, column: Int) -> Element {
        return storage[indexFor(row: row, column: column)]
    }

    /// Set an element at the given row and column.
    @inlinable mutating public func setElement(_ element: T, row: Int, column: Int) {
        storage[indexFor(row: row, column: column)] = element
    }

    /// Transpose the elements of the matrix in-place
    public mutating func transpose() {
        var newStorage = ContiguousArray<Element>()
        newStorage.reserveCapacity(storage.count)
        for columnIndex in 0..<columnCount {
            for rowIndex in 0..<rowCount{
                newStorage.append(self[rowIndex, columnIndex])
            }
        }
        storage = newStorage
        let temp = rowCount
        rowCount = columnCount
        columnCount = temp
    }
}

extension ContiguousMatrix: Equatable where Element: Equatable {}
extension ContiguousMatrix: Hashable where Element: Hashable {}
extension ContiguousMatrix: MatrixOperations where Element: Numeric {}
