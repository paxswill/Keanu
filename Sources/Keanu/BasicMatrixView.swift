/// A basic view over a row in a matrix.
public struct BasicRowView<M: MatrixProtocol, T>: RowViewProtocol
where
    M.Element == T
{
    /// The type of the elements contained in the matrix.
    public typealias Element = T

    /// The type of the matrix backing this view.
    public typealias SourceMatrix = M

    /// The matrix this view is representing.
    public var matrix: SourceMatrix

    /// The row in the source matrix this view covers.
    public let rowIndex: Int

    /// Create a basic row view.
    public init(_ matrix: SourceMatrix, index: Int) {
        self.matrix = matrix
        rowIndex = index
    }
}
extension BasicRowView: Equatable where Element: Equatable {}
extension BasicRowView: Hashable where Element: Hashable {}
extension BasicRowView: VectorOperations where Element: Numeric {}

/// A basic view over a column in a matrix.
public struct BasicColumnView<M: MatrixProtocol, T>: ColumnViewProtocol
where
    M.Element == T
{
    /// The type of the elements contained in the matrix.
    public typealias Element = T

    /// The type of the matrix backing this view.
    public typealias SourceMatrix = M

    /// The matrix this view is representing.
    public var matrix: SourceMatrix

    /// The column in the source matrix this view covers.
    public let columnIndex: Int

    /// Create a basic column view.
    public init(_ matrix: SourceMatrix, index: Int) {
        self.matrix = matrix
        columnIndex = index
    }
}
extension BasicColumnView: Equatable where Element: Equatable {}
extension BasicColumnView: Hashable where Element: Hashable {}
extension BasicColumnView: VectorOperations where Element: Numeric {}
