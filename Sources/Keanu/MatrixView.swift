public class MatrixView<T> {
    public typealias Element = T
    public typealias Index = Int
    public private(set) var matrix: Matrix<T>
    private let viewType: Order
    private let orderIndex: Index
    
    fileprivate init(_ matrix: Matrix<Element>, order: Order, index: Index) {
        self.matrix = matrix
        self.viewType = order
        orderIndex = index
    }
}

public class RowView<T>: MatrixView<T> {
    internal init(_ matrix: Matrix<Element>, index: Index) {
        super.init(matrix, order: .rowMajor, index: index)
    }
}

public class ColumnView<T>: MatrixView<T> {
    internal init(_ matrix: Matrix<Element>, index: Index) {
        super.init(matrix, order: .columnMajor, index: index)
    }
}

extension MatrixView: MutableCollection {
    public var startIndex: Index {
        return Index(0)
    }
    
    public var endIndex: Index {
        switch viewType {
        case .rowMajor:
            return matrix.columnCount
        case .columnMajor:
            return matrix.rowCount
        }
    }
    
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
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
    public static func == (lhs: MatrixView<T>, rhs: MatrixView<T>) -> Bool {
        // NOTE: possible vectorization point
        return lhs.count == rhs.count && zip(lhs, rhs).allSatisfy { $0 == $1 }
    }

    public func hash(into hasher: inout Hasher) {
        self.forEach { hasher.combine($0) }
    }
}

