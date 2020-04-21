// Declaring an explicit protocol for these to distinguish them from the
// similar operations that have been added to Collection (which MatrixProtocol
// conforms to).
/// Protocol providing an extension opint for matrix operations.
public protocol MatrixOperations:
    MatrixProtocol
where
    // `Element: Numeric` is implied by the Views being constrained to
    // VectorOperations (which applies a constraint to
    // Collection.Element: Numeric
    RowView: VectorOperations,
    ColumnView: VectorOperations
{
    static func .+ (_: Self, _: Self) -> Self
    static func .+ (matrix: Self, scalar: Element) -> Self
    static func .+ (scalar: Element, matrix: Self) -> Self
    static func .- (lhs: Self, rhs: Self) -> Self
    static func .- (matrix: Self, scalar: Element) -> Self
    func dot(_ other: Self) -> Element
    func dot<T: Collection>(_ other: T) -> Element where T.Element == Element

}

extension MatrixOperations where Element: AdditiveArithmetic {
    /// Add two matrices together element-wise, returning the results.
        assert(lhs.rowCount == rhs.rowCount)
        assert(lhs.columnCount == rhs.columnCount)
    public static func .+ (lhs: Self, rhs: Self) -> Self {
        let summed: [Element] = zip(lhs, rhs).map(+)
        let rows: [[Element]] = stride(from: 0, to: summed.count, by: lhs.rowCount).map {
            Array(summed[$0..<($0 + lhs.rowCount)])
        }
        return Self(rows)
    }

    /// Add a scalar to each element in the matrix, returning the results.
    public static func .+ (matrix: Self, scalar: Element) -> Self {
        let summed: [Element] = matrix.map { $0 + scalar }
        let rows: [[Element]] = stride(from: 0, to: summed.count, by: matrix.rowCount).map {
            Array(summed[$0..<($0 + matrix.rowCount)])
        }
        return Self(rows)
    }

    /// Add a scalar to each element in the matrix, returning the individual results.
    public static func .+ (scalar: Element, matrix: Self) -> Self {
        return matrix .+ scalar
    }

    /// Subtract two matrices element-wise, returning the results.
        assert(lhs.rowCount == rhs.rowCount)
        assert(lhs.columnCount == rhs.columnCount)
    public static func .- (lhs: Self, rhs: Self) -> Self {
        let difference: [Element] = zip(lhs, rhs).map(-)
        let rows: [[Element]] = stride(from: 0, to: difference.count, by: lhs.rowCount).map {
            Array(difference[$0..<($0 + lhs.rowCount)])
        }
        return Self(rows)
    }

    /// Subtract a scalar from each element in the matrix, returning the results.
    public static func .- (matrix: Self, scalar: Element) -> Self {
        let difference: [Element] = matrix.map { $0 - scalar }
        let rows: [[Element]] = stride(from: 0, to: difference.count, by: matrix.rowCount).map {
            Array(difference[$0..<($0 + matrix.rowCount)])
        }
        return Self(rows)
    }

    /// Return the dot product of two matrices that are vectors.
    public func dot(_ other: Self) -> Element {
        assert(isVector)
        assert(other.isVector)
        assert(count == other.count)
        let products = zip(self, other).map(*)
        // TODO: use a better algorithm for summation like Kahan's
        return products.reduce(Element.zero, +)
    }

    /// Return the dot product of this matrix and an array of elements.
    public func dot<T: Collection>(_ other: T) -> Element where T.Element == Element {
        assert(isVector)
        assert(count == other.count)
        let products = zip(self, other).map(*)
        // TODO: use a better algorithm for summation like Kahan's
        return products.reduce(Element.zero, +)
    }
}
