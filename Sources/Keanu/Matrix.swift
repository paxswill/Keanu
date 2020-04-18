// I would like to put this within the Matrix class, but it is not a
// generic type, so it's easier to use it when it's outside.
public enum Order {
    case rowMajor
    case columnMajor
}

public class Matrix<T>: ExpressibleByArrayLiteral {
    public typealias Element = T
    public typealias Index = Int

    public let rowCount: Index
    public let columnCount: Index
    public private(set) var order: Order
    @usableFromInline internal var storage: ContiguousArray<Element> = []

    // MARK: Initializers

    public init(rows: Index, columns: Index, initialValue: Element, order: Order = .rowMajor) {
        rowCount = rows
        columnCount = columns
        self.order = order
        storage = ContiguousArray(repeating: initialValue, count: rows * columns)
    }

    // TODO: genericize the elementArrays argument
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

    required public convenience init(arrayLiteral: [Element]...) {
        self.init(arrayLiteral)
    }

    // MARK: Aggregate access

    public var count: Int {
        return storage.count
    }

    // MARK: Element Access

    public func row(_ rowIndex: Index) -> RowView<Element> {
        return RowView(self, index: rowIndex)
    }

    public func column(_ columnIndex: Index) -> ColumnView<Element> {
        return ColumnView(self, index: columnIndex)
    }

    @inlinable internal func indexFor(row: Index, column: Index) -> Index {
        switch order {
        case .rowMajor:
            return column + row * columnCount
        case .columnMajor:
            return row + column * rowCount
        }
    }

    @inlinable public func getElement(row: Index, column: Index) -> Element {
        return storage[indexFor(row: row, column: column)]
    }

    @inlinable public func setElement(_ element: Element, row: Index, column: Index) {
        storage[indexFor(row: row, column: column)] = element
    }

    subscript(row: Index, column: Index) -> Element {
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
    public func makeIterator() -> IndexingIterator<ContiguousArray<Element>> {
        return storage.makeIterator()
    }
}

// MARK: Type Restricted Protocols

extension Matrix where Element: AdditiveArithmetic {
    public convenience init(rows: Index, columns: Index, order: Order = .rowMajor) {
        self.init(rows: rows, columns: columns, initialValue: Element.zero, order: order)
    }
}

extension Matrix: Equatable where Element: Hashable {
    public static func == (lhs: Matrix<Element>, rhs: Matrix<Element>) -> Bool {
        // NOTE: possible vectorization point
        return lhs.count == rhs.count && zip(lhs, rhs).allSatisfy { $0 == $1 }
    }

    public func hash(into hasher: inout Hasher) {
        self.forEach { hasher.combine($0) }
    }
}
