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

    /// A boolean for if the matrix is empty or not.
    var isEmpty: Bool { get }

    /// A boolean for if the matrix is square (same number of rows and columns).
    var isSquare: Bool { get }

    /// A boolean for if the matrix is a vector (there is either only one row
    /// or one column).
    var isVector: Bool { get }

    /// A boolean for if there is only one element in the matrix.
    var isScalar: Bool { get }

    /// If the matrix is a vector (`isVector` is true), this property will
    /// return an array of that vector.
    var vector: [Element]? { get }

    /// If the matrix is a scalar (`isScalar` is true), this property will
    /// return the single value in the matrix.
    var scalar: Element? { get }

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

extension MatrixProtocol where RowView.Element == Element, ColumnView.Element == Element {
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

    /// A boolean for if the matrix is empty or not.
    public var isEmpty: Bool { count == 0 }

    /// A boolean for if the matrix is square (same number of rows and columns).
    public var isSquare: Bool { rowCount == columnCount }

    /// A boolean for if the matrix is a vector (there is either only one row
    /// or one column).
    public var isVector: Bool { rowCount == 1 || columnCount == 1 }

    /// A boolean for if there is only one element in the matrix.
    public var isScalar: Bool { count == 1 }

    /// If the matrix is a vector, this property will return an array of that
    /// vector.
    public var vector: [Element]? {
        guard isVector else {
            return nil
        }
        if rowCount == 1 {
            return Array(row(0))
        } else {
            return Array(column(0))
        }
    }

    /// If the matrix is a scalar (`isScalar` is true), this property will
    /// return the single value in the matrix.
    public var scalar: Element? {
        guard isScalar else {
            return nil
        }
        return self[0, 0]
    }

    /// Access elements in the matrix with a *row*, *column* subscript.
    public subscript(row: Int, column: Int) -> Element {
        return getElement(row: row, column: column)
    }

    /// Access elements in the matrix by (row, column) tuple.
    public subscript(index: Index) -> Element {
        return getElement(row: index.row, column: index.column)
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

// AdditiveArithmetic (for .zero) and ExpressibleByIntegerLiteral (for
// type casting `1`). The closest standard library protocol for this is Numeric,
// but this is a bit more precise.
extension MatrixProtocol where Element: AdditiveArithmetic & ExpressibleByIntegerLiteral {
    /// Generate the identity matrix with the given dimensions.
    public static func identityMatrix(size: Int) -> Self {
        let arrays: [[Element]] = (0..<size).map {
            var array = Array(repeating: Element.zero, count: size)
            array[$0] = 1 as Element
            return array
        }
        return Self(arrays)
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
