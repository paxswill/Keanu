extension MatrixProtocol where Element: Numeric {
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
