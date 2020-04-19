// I would like to put this within the Matrix class, but it is not a
// generic type, so it's easier to use it when it's outside.
/// An enum for representing if a matrix is using a row-major or column-major
/// layout.
///
/// This difference exposes itself in a few places, mainly when iterating over
/// elements in the matrix or when using vector operations on the elements of
/// the matrix.
public enum Order {
    /// Row-major ordering.
    case rowMajor

    /// Column-major ordering.
    case columnMajor
}

/// Type representing a two-dimensional matrix.
///
/// All indexes start from 0. The dimensions of the matrix are immutable, but
/// each element's value *is* mutable.
public class Matrix<T>: ExpressibleByArrayLiteral {
    /// The type of elements contained within this matrix.
    public typealias Element = T

    /// The type of the indicies used to access elements in this matrix.
    public typealias Index = Int

    /// The number of rows in the matrix.
    public let rowCount: Index

    /// The number of columns in the matrix.
    public let columnCount: Index

    /// Whether this matrix is using a row-major or column-major representation
    /// internally.
    public private(set) var order: Order

    @usableFromInline internal var storage: ContiguousArray<Element> = []

    // MARK: Initializers

    /// Initialize a matrix with a single repeated value.
    public init(rows: Index, columns: Index, initialValue: Element, order: Order = .rowMajor) {
        rowCount = rows
        columnCount = columns
        self.order = order
        storage = ContiguousArray(repeating: initialValue, count: rows * columns)
    }

    // TODO: genericize the elementArrays argument
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
        _ elementArrays: [[Element]], sourceOrder: Order = .rowMajor, order: Order = .rowMajor
    ) {
        switch sourceOrder {
        case .rowMajor:
            rowCount = elementArrays.count
            columnCount = elementArrays[0].count
        case .columnMajor:
            rowCount = elementArrays[0].count
            columnCount = elementArrays.count
        }
        storage = ContiguousArray()
        storage.reserveCapacity(rowCount * columnCount)
        self.order = order
        // NOTE: While `storage` has space *reserved* for the contents, it
        // doesn't have any actual data so we need to append everything in the
        // appropriate order (as opposed to just setting the proper index if the
        // array was initialized)
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

    /// Create a new matrix with an array literal.
    ///
    /// The given array literal must be a row-major representation, and the
    /// resulting Matrix will also be stored in a row-major format. If you need
    /// control over those defaults, the `init(_:, sourceOrder:, order:)`
    /// initializer is a better choice.
    ///
    /// - Parameter arrayLiteral: a variadic argument of arrays of Elements.
    required public convenience init(arrayLiteral: [Element]...) {
        self.init(arrayLiteral)
    }

    // MARK: Aggregate access

    /// The total number of elements in the matrix.
    public var count: Int {
        return storage.count
    }

    // MARK: Element Access

    /// Returns a `RowView` for the given row.
    public func row(_ rowIndex: Index) -> RowView<Element> {
        return RowView(self, index: rowIndex)
    }

    /// Returns a `ColumnView` for the given column.
    public func column(_ columnIndex: Index) -> ColumnView<Element> {
        return ColumnView(self, index: columnIndex)
    }

    /// Internal helper the calculates the proper index in the backing store for
    /// the given row and column.
    @inlinable internal func indexFor(row: Index, column: Index) -> Index {
        switch order {
        case .rowMajor:
            return column + row * columnCount
        case .columnMajor:
            return row + column * rowCount
        }
    }

    /// Get an element at the given row and column.
    @inlinable public func getElement(row: Index, column: Index) -> Element {
        return storage[indexFor(row: row, column: column)]
    }

    /// Set an element at the given row and column.
    @inlinable public func setElement(_ element: Element, row: Index, column: Index) {
        storage[indexFor(row: row, column: column)] = element
    }

    /// Access elements in the matrix with a *row*, *column* subscript.
    ///
    /// The order will always be (*row*, *column*).
    public subscript(row: Index, column: Index) -> Element {
        get {
            return getElement(row: row, column: column)
        }
        set {
            setElement(newValue, row: row, column: column)
        }

    }
}

// MARK: Standard Protocols

extension Matrix: Sequence {
    /// Create an iterator over each Element in a matrix.
    ///
    /// The order of elements from the iterator will depend on how the matrix is
    /// stored internally, eithr row-major or column-major.
    ///
    /// - Returns: An iterator over each element individually.
    public func makeIterator() -> IndexingIterator<ContiguousArray<Element>> {
        return storage.makeIterator()
    }
}

// MARK: Type Restricted Protocols

extension Matrix where Element: AdditiveArithmetic {
    /// Initializer for numerical types, where the default fill value is 0.
    public convenience init(rows: Index, columns: Index, order: Order = .rowMajor) {
        self.init(rows: rows, columns: columns, initialValue: Element.zero, order: order)
    }
}

extension Matrix: Equatable where Element: Equatable {
    /// Returns whether or not two matrices are equal based on each element.
    public static func == (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        // NOTE: This function can probably be vectorized
        // Checking both counts also transitively checks the full count
        if lhs.rowCount != rhs.rowCount || lhs.columnCount != rhs.columnCount {
            return false
        } else if lhs.order == rhs.order {
            // If they have the same ordering, we can just compare the
            // iterator outputs
            return lhs.count == rhs.count && zip(lhs, rhs).allSatisfy { $0 == $1 }
        } else {
            // Since the order is different, we can either transpose one
            // of them and then compare the iterators, or we can compare
            // each element individually.
            // TODO: once a transpose method is added, use that
            for row in 0..<lhs.rowCount {
                for column in 0..<rhs.columnCount {
                    if lhs[row, column] != rhs[row, column] {
                        return false
                    }
                }
            }
            return true
        }
    }
}

extension Matrix: Hashable where Element: Hashable {
    /// Allow matrices to be hashed on their values.
    ///
    /// The hash value *does* depend on the `order` of the matrix.
    ///
    /// - Parameter hasher: The Hasher instance used to calculate the hash.
    // The parameter docstring is to get swift-format to shut up.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rowCount)
        hasher.combine(columnCount)
        // Using rowMajor for the order the items are added to the hasher as
        // it's the default order.
        switch order {
        case .rowMajor:
            forEach { hasher.combine($0) }
        case .columnMajor:
            for row in 0..<rowCount {
                for column in 0..<columnCount {
                    hasher.combine(self[row, column])
                }
            }
        }
    }
}
