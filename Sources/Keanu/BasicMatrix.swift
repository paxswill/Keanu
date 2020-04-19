/// A basic implementation of a matrix data type.
///
/// This implementation should be able to be used on all platforms Swift
/// supports.
public struct BasicMatrix<T>: MutableMatrixProtocol, ContiguousMatrixProtocol {
    /// The type of elements contained within this matrix.
    public typealias Element = T

    /// A single-value type that can be used to access elements by index.
    public typealias Index = MatrixIndex

    /// The type of the views over individual rows of the matrix.
    public typealias RowView = MutableBasicRowView<Element>

    /// The type of the views over individual columns of the matrix.
    public typealias ColumnView = MutableBasicColumnView<Element>

    /// The number of rows in the matrix.
    public let rowCount: Int

    /// The number of columns in the matrix.
    public let columnCount: Int

    /// Whether this matrix is using a row-major or column-major representation
    /// internally.
    public let order: Order

    // This would normally be private, but needs to be internal to be usable
    // from inline.
    @usableFromInline internal var storage: ContiguousArray<Element>

    /// Initialize a matrix with a single repeated value.
    public init(rows: Int, columns: Int, initialValue: T, order: Order = .rowMajor) {
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
        } else if order == .columnMajor {
            for sourceColumn in 0..<elementArrays[0].count {
                for sourceRow in 0..<elementArrays.count {
                    storage.append(elementArrays[sourceRow][sourceColumn])
                }
            }
        } else if order == .rowMajor {
            for sourceColumn in 0..<elementArrays.count {
                for sourceRow in 0..<elementArrays[0].count {
                    storage.append(elementArrays[sourceColumn][sourceRow])
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
}

extension BasicMatrix: Equatable where Element: Equatable {}
extension BasicMatrix: Hashable where Element: Hashable {}
