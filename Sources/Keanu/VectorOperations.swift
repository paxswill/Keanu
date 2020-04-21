/// Protocol providing an extension point for vector operations over collections.
public protocol VectorOperations: Collection where Element: Numeric {
    static func .+ <T: Collection>(lhs: Self, rhs: T) -> [Element] where T.Element == Element
    static func .+ (vector: Self, scalar: Element) -> [Element]
    static func .+ (scalar: Element, vector: Self) -> [Element]
    static func .- <T: Collection>(lhs: Self, rhs: T) -> [Element] where T.Element == Element
    static func .- (vector: Self, scalar: Element) -> [Element]
    static func .* (lhs: Self, rhs: Self) -> [Element]
    static func .* (vector: Self, scalar: Element) -> [Element]
    static func .* (scalar: Element, vector: Self) -> [Element]
    func dot<T: Collection>(_ other: T) -> Element where T.Element == Element
}

extension VectorOperations {
    /// Add the elements from two views together, returning the results.
    public static func .+ <T: Collection>(lhs: Self, rhs: T) -> [Element]
    where T.Element == Element {
        assert(lhs.count == rhs.count)
        return zip(lhs, rhs).map(+)
    }

    /// Add a scalar to each element in the view, returning the results.
    public static func .+ (vector: Self, scalar: Element) -> [Element] {
        return vector.map { $0 + scalar }
    }

    /// Add a scalar to each element in the view, returning the results.
    public static func .+ (scalar: Element, vector: Self) -> [Element] {
        return vector .+ scalar
    }

    /// Subtract each element of the second view from the first, returning results.
    public static func .- <T: Collection>(lhs: Self, rhs: T) -> [Element]
    where T.Element == Element {
        assert(lhs.count == rhs.count)
        return zip(lhs, rhs).map(-)
    }

    /// Subtract a scalar from each element of a view, returning the results.
    public static func .- (vector: Self, scalar: Element) -> [Element] {
        return vector.map { $0 - scalar }
    }

    /// Return the results of multiplying each corresponding element of each operand together.
    public static func .* (lhs: Self, rhs: Self) -> [Element] {
        precondition(lhs.count == rhs.count)
        return zip(lhs, rhs).map(*)
    }

    /// Return the result of multiplying each element of the vector by a scalar.
    public static func .* (vector: Self, scalar: Element) -> [Element] {
        return vector.map { $0 * scalar }
    }

    /// Return the result of multiplying each element of the vector by a scalar.
    public static func .* (scalar: Element, vector: Self) -> [Element] {
        return vector .* scalar
    }

    /// Return the dot product of two vectors.
    public func dot<T: Collection>(_ other: T) -> Element where T.Element == Element {
        precondition(
            count == other.count,
            """
            The dot product requires both vectors to be the same length.
            """
        )
        let products = zip(self, other).map(*)
        // TODO: use a better algorithm for summation like Kahan's
        return products.reduce(Element.zero, +)
    }
}

extension Array: VectorOperations where Array.Element: Numeric {}
