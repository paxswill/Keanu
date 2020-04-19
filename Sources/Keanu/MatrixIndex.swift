/// Type representing an individual index into a matrix.
public struct MatrixIndex: Equatable, Hashable {
    let row: Int
    let column: Int

    /// Create a new MatrixIndex from a (row, column) pair of arguments.
    public init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

extension MatrixIndex: Comparable {
    /// Returns whether or not a matrix index is before another index, in
    /// row-major ordering.
    public static func < (lhs: MatrixIndex, rhs: MatrixIndex) -> Bool {
        if lhs.row == rhs.row {
            return lhs.column < rhs.column
        } else {
            return lhs.row < rhs.row
        }
    }
}
