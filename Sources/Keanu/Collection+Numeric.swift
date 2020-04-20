extension Collection where Element: Numeric {
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
