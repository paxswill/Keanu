/// Shared functionality between ColumnView and RowView.
public class MatrixView<T> {
    /// The type of element being stored within the matrix.
    public typealias Element = T

    /// The type of the values used to access elements.
    public typealias Index = Int

    /// The matrix that this view belongs to.
    public private(set) var matrix: Matrix<T>

    /// Whether this view is a row or column view.
    private let viewType: Order

    /// The index of the row or column in the matrix that this view covers.
    private let orderIndex: Index

    fileprivate init(_ matrix: Matrix<Element>, order: Order, index: Index) {
        self.matrix = matrix
        self.viewType = order
        orderIndex = index
    }
}

/// A view over a single row in the matrix.
public class RowView<T>: MatrixView<T> {
    internal init(_ matrix: Matrix<Element>, index: Index) {
        super.init(matrix, order: .rowMajor, index: index)
    }
}

/// A view over a single column in the matrix.
public class ColumnView<T>: MatrixView<T> {
    internal init(_ matrix: Matrix<Element>, index: Index) {
        super.init(matrix, order: .columnMajor, index: index)
    }
}

extension MatrixView: MutableCollection {
    /// The beginning of the indices for this collection.
    public var startIndex: Index {
        return Index(0)
    }

    /// The index for the position just past the last element in this
    /// collection.
    public var endIndex: Index {
        switch viewType {
        case .rowMajor:
            return matrix.columnCount
        case .columnMajor:
            return matrix.rowCount
        }
    }

    /// The index immediately after the given index.
    // Required to conform to Collection
    public func index(after i: Index) -> Index {
        return i + 1
    }

    /// Access a specific element in this view.
    public subscript(index: Index) -> Element {
        get {
            switch viewType {
            case .rowMajor:
                return matrix.getElement(row: orderIndex, column: index)
            case .columnMajor:
                return matrix.getElement(row: index, column: orderIndex)
            }
        }
        set {
            switch viewType {
            case .rowMajor:
                matrix.setElement(newValue, row: orderIndex, column: index)
            case .columnMajor:
                matrix.setElement(newValue, row: index, column: orderIndex)
            }
        }
    }
}

extension MatrixView: Equatable where Element: Hashable {
    /// Return a boolean if this view and another view have the same values and
    /// both are the same kind of view (row vs. column).
    public static func == (lhs: MatrixView<T>, rhs: MatrixView<T>) -> Bool {
        // NOTE: possible vectorization point
        return lhs.count == rhs.count && lhs.viewType == rhs.viewType
            && zip(lhs, rhs).allSatisfy { $0 == $1 }
    }

    /// Generate a hash value for this view.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(viewType)
        hasher.combine(orderIndex)
        self.forEach { hasher.combine($0) }
    }
}
