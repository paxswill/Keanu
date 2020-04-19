/// Type representing a two-dimensional matrix.
///
/// All indexes start from 0. The dimensions of the matrix are immutable, but
/// each element's value *is* mutable.
public protocol MatrixProtocol: Collection, ExpressibleByArrayLiteral where Index == MatrixIndex {
    /// The type of elements contained within this matrix.
    associatedtype Element

    associatedtype RowView: RowViewProtocol
    associatedtype ColumnView: ColumnViewProtocol

    /// The number of rows in the matrix.
    var rowCount: Int { get }

    /// The number of columns in the matrix.
    var columnCount: Int { get }

    /// The total number of elements in the matrix.
    var count: Int { get }

    /// Initialize a matrix with a single repeated value.
    init(rows: Int, columns: Int, initialValue: Element)

    // TODO: Genericize the elementArrays argument to allow
    // Sequence<Sequence<Element>>
    /// Initialize a matrix from a two-dimensional array of Elements.
    ///
    /// - Parameter elementArrays: A 2D-array of Elements. The inner arrays
    ///   *must* all have the same number of elements.
    init(_ elementArrays: [[Element]])

    /// Create a new matrix with an array literal.
    ///
    /// The given array literal must be a row-major representation, and the
    /// resulting Matrix will also be stored in a row-major format. If you need
    /// control over those defaults, the `init(_:, sourceOrder:, order:)`
    /// initializer is a better choice.
    ///
    /// - Parameter arrayLiteral: a variadic argument of arrays of Elements.
    init(arrayLiteral: [Element]...)

    // MARK: Element Access

    /// Returns a `RowView` for the given row.
    func row(_ rowIndex: Int) -> RowView

    /// Returns a `ColumnView` for the given column.
    func column(_ columnIndex: Int) -> ColumnView

    /// Get an element at the given row and column.
    func getElement(row: Int, column: Int) -> Element

    /// Access elements in the matrix with a *row*, *column* subscript.
    ///
    /// The order will always be (*row*, *column*).
    subscript(row: Int, column: Int) -> Element { get }

    /// Access elements in the matrix by (row, column) tuple.
    subscript(index: Index) -> Element { get }
}

extension MatrixProtocol {
    /// Access elements in the matrix with a *row*, *column* subscript.
    public subscript(row: Int, column: Int) -> Element {
        return getElement(row: row, column: column)
    }

    /// Access elements in the matrix by (row, column) tuple.
    public subscript(index: Index) -> Element {
        return getElement(row: index.row, column: index.column)
    }

    /// The first index in the collection.
    public var startIndex: Index {
        MatrixIndex(0, 0)
    }

    /// The index just past the last filled index.
    public var endIndex: Index {
        // Because the default ordering is row-major, this index is for the next
        // row, column 0. Because the rows and columns are 0 indexed, we can use
        // rowCount directly.
        MatrixIndex(rowCount, 0)
    }

    /// The total number of elements in the matrix.
    public var count: Int {
        return rowCount * columnCount
    }

    /// Return the index immediately after the given index, in row-major order.
    public func index(after index: Index) -> Index {
        let combinedNext = index.row * columnCount + index.column + 1
        return Index(combinedNext / columnCount, combinedNext % columnCount)
    }

    /// Create a matrix from a two dimensional array literal.
    public init(arrayLiteral elements: [Element]...) {
        self.init(elements)
    }
}

extension MatrixProtocol where Element: AdditiveArithmetic {
    /// Initializer for numerical types, where the default fill value is 0.
    public init(rows: Int, columns: Int) {
        self.init(rows: rows, columns: columns, initialValue: Element.zero)
    }
}

extension MatrixProtocol where Self.Element: Equatable {
    /// Returns whether or not two matrices are equal based on each element.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // NOTE: This function can probably be vectorized
        // Checking both counts also transitively checks the full count
        if lhs.rowCount != rhs.rowCount || lhs.columnCount != rhs.columnCount {
            return false
        } else {
            // If they have the same ordering, we can just compare the
            // iterator outputs
            return zip(lhs, rhs).allSatisfy { $0 == $1 }
        }
    }
}

extension MatrixProtocol where Element: Hashable {
    /// Allow matrices to be hashed on their values.
    ///
    /// The hash value *does* depend on the `order` of the matrix.
    ///
    /// - Parameter hasher: The Hasher instance used to calculate the hash.
    // The parameter docstring is to get swift-format to shut up.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rowCount)
        hasher.combine(columnCount)
        forEach { hasher.combine($0) }
    }
}
