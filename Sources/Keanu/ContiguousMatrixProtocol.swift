/// Protocol for Matrices that have their elements laid out contiguously in
/// memory.
public protocol ContiguousMatrixProtocol: MatrixProtocol {
    /// Whether this matrix is using a row-major or column-major representation
    /// internally.
    var order: Order { get }

    // TODO: Considering how to expose the contiguous memory
    //var storage: ContiguousArray<Element> { get }

    /// Initialize a matrix with a single repeated value.
    init(rows: Int, columns: Int, initialValue: Element, order: Order)

    // TODO: Like MatrixProtocol, genericize elementArrays
    /// Initialize a matrix from a two-dimensional array of Elements.
    ///
    /// - Parameters:
    ///     - elementArrays: A 2D-array of Elements. The inner arrays *must* all
    ///       have the same number of elements.
    ///     - sourceOrder: Declare whether `elementArrays` is a row-major or
    ///       column-major representation of a matrix.
    ///     - order: What the newly created matrix should use for storing the
    ///       elements.
    init(_ elementArrays: [[Element]], sourceOrder: Order, order: Order)
}
