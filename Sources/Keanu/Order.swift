/// An enum for representing if a matrix is using a row-major or column-major
/// layout.
///
/// This difference exposes itself in a few places, mainly when iterating over
/// elements in the matrix or when using vector operations on the elements of
/// the matrix.
public enum Order {
    /// Row-major ordering.
    case rowMajor

    /// Column-major ordering.
    case columnMajor
}
