/// Protocol for matrices that allow modification of their elements.
public protocol MutableMatrixProtocol: MatrixProtocol, MutableCollection
where
    RowView: MutableRowViewProtocol,
    ColumnView: MutableColumnViewProtocol
{
    /// Set an element at the given row and column.
    mutating func setElement(_ element: Element, row: Int, column: Int)

    /// Access elements in the matrix with a *row*, *column* subscript.
    ///
    /// The order will always be (*row*, *column*).
    subscript(row: Int, column: Int) -> Element { get set }
}

extension MutableMatrixProtocol {
    /// Access elements in the matrix with a *row*, *column* subscript.
    public subscript(row: Int, column: Int) -> Element {
        get {
            return getElement(row: row, column: column)
        }
        set {
            setElement(newValue, row: row, column: column)
        }
    }

    /// Access elements in the matrix by (row, column) tuple.
    public subscript(index: Index) -> Element {
        get {
            return getElement(row: index.row, column: index.column)
        }
        set {
            setElement(newValue, row: index.row, column: index.column)
        }
    }
}
