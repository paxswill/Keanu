/// A basic view over a row in a matrix.
public struct BasicRowView<T>: RowViewProtocol {
    /// The type of the elements contained in the matrix.
    public typealias Element = T

    /// The matrix this view is representing.
    public var matrix: BasicMatrix<T>

    /// The row in the source matrix this view covers.
    public let rowIndex: Int

    /// Create a basic row view.
    public init(_ matrix: BasicMatrix<T>, index: Int) {
        self.matrix = matrix
        rowIndex = index
    }
}
extension BasicRowView: Equatable where Element: Equatable {}
extension BasicRowView: Hashable where Element: Hashable {}
extension BasicRowView: VectorOperations where Element: Numeric {}

/// A basic view over a column in a matrix.
public struct BasicColumnView<T>: ColumnViewProtocol {
    /// The type of the elements contained in the matrix.
    public typealias Element = T

    /// The matrix this view is representing.
    public var matrix: BasicMatrix<T>

    /// The column in the source matrix this view covers.
    public let columnIndex: Int

    /// Create a basic column view.
    public init(_ matrix: BasicMatrix<T>, index: Int) {
        self.matrix = matrix
        columnIndex = index
    }
}
extension BasicColumnView: Equatable where Element: Equatable {}
extension BasicColumnView: Hashable where Element: Hashable {}
extension BasicColumnView: VectorOperations where Element: Numeric {}
