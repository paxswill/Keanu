internal func hashOf<T: Hashable>(_ value: T) -> Int {
    var hasher = Hasher()
    hasher.combine(value)
    return hasher.finalize()
}
