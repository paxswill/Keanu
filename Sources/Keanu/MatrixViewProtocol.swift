// MARK: Common view functionality

/// Protocol for a view of a single row or column in a matrix.
public protocol MatrixViewProtocol: Collection
where
    Index == Int,
    SourceMatrix.Element == Element
{
    associatedtype SourceMatrix: MatrixProtocol
    //associatedtype Element = SourceMatrix.Element

    /// The matrix that this view belongs to.
    var matrix: SourceMatrix { get }

    /// The index of the row or column in the matrix that this view covers.
    var sourceIndex: Index { get }

    /// Create a view of a row or column in a matrix.
    init(_ matrix: SourceMatrix, index: Index)
}

/// Protocol for views over mutable matrices.
public protocol MutableMatrixViewProtocol: MatrixViewProtocol, MutableCollection
where SourceMatrix: MutableMatrixProtocol {
    var matrix: SourceMatrix { get set }
}

extension MatrixViewProtocol where Element: Equatable {
    /// Return a boolean if this view and another view have the same values and
    /// both are the same kind of view (row vs. column).
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // NOTE: possible vectorization point
        return lhs.count == rhs.count && zip(lhs, rhs).allSatisfy { $0 == $1 }
    }
}

extension MatrixViewProtocol where Element: Hashable {
    /// Generate a hash value for this view.
    public func hash(into hasher: inout Hasher) {
        self.forEach { hasher.combine($0) }
    }
}

// MARK: Row View

/// A view over a single row in the matrix.
public protocol RowViewProtocol: MatrixViewProtocol {
    var rowIndex: Index { get }
}

extension RowViewProtocol {
    /// The row in the source matrix this view covers.
    public var sourceIndex: Int { rowIndex }

    /// The index of the first column in the row.
    public var startIndex: Index { 0 }

    /// The index of the column just past the last existing column.
    public var endIndex: Index { matrix.columnCount }

    /// Returns the next index after the given index.
    public func index(after i: Index) -> Index {
        return i + 1
    }

    /// Access the elements in this row of the matrix.
    public subscript(columnIndex: Index) -> Element {
        return matrix[sourceIndex, columnIndex]
    }
}

/// A view over a single row in a mutable matrix.
public protocol MutableRowViewProtocol: RowViewProtocol, MutableMatrixViewProtocol {
    var matrix: SourceMatrix { get set }
}

extension MutableRowViewProtocol {
    /// Access the elements in this row of the matrix.
    public subscript(columnIndex: Index) -> Element {
        get {
            return matrix[sourceIndex, columnIndex]
        }
        set {
            matrix[sourceIndex, columnIndex] = newValue
        }
    }
}

// MARK: Column View

/// A view over a single column in the matrix.
public protocol ColumnViewProtocol: MatrixViewProtocol {
    var columnIndex: Index { get }
}

extension ColumnViewProtocol {
    /// The column in the source matrix this view covers.
    public var sourceIndex: Int { columnIndex }

    /// The index of the first column in the row.
    public var startIndex: Index { 0 }

    /// The index of the row just past the last existing row.
    public var endIndex: Index { matrix.rowCount }

    /// Returns the next index after the given index.
    public func index(after i: Index) -> Index {
        return i + 1
    }

    /// Access the elements in this column of the matrix.
    public subscript(rowIndex: Index) -> Element {
        return matrix[rowIndex, sourceIndex]
    }
}

/// A view over a single column in a mutable matrix.
public protocol MutableColumnViewProtocol: ColumnViewProtocol, MutableMatrixViewProtocol {
    var matrix: SourceMatrix { get set }
}

extension MutableColumnViewProtocol {
    /// Access the elements in this row of the matrix.
    public subscript(rowIndex: Index) -> Element {
        get {
            return matrix[rowIndex, sourceIndex]
        }
        set {
            matrix[rowIndex, sourceIndex] = newValue
        }
    }
}
