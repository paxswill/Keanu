/// A type supporting basic arithmetic.
///
/// The protocol inheritance tree from Numeric up defines addition, subtraction
/// and multiplication, so this protocol defines division, remainders, and
/// comparison operators.
/// FloatingPoint and BinaryInteger already implement these, so those protocols
/// are extended to conform with this protocol.
public protocol Arithmetic: Numeric {
    // MARK: Comparisons

    /// Returns a boolean whether the first operand is less than the second.
    static func < (_: Self, _: Self) -> Bool

    /// Returns a boolean whether the first operand is less than or equal to the
    /// second.
    static func <= (_: Self, _: Self) -> Bool

    /// Returns a boolean whether or not the first operand is greater than the
    /// second.
    static func > (_: Self, _: Self) -> Bool

    /// Returns a boolean whether or not the first operand is greater than or
    /// equal to the second.
    static func >= (_: Self, _: Self) -> Bool

    // MARK: Division

    /// Returns the result of dividing the first operand by the second.
    static func / (_: Self, _: Self) -> Self

    /// Divides the first operand by the second and stores the result in the
    /// first.
    static func /= (_: inout Self, _: Self)

    /// Returns the result of multiplying the first operand by the second.
    static func * (_: Self, _: Self) -> Self

    /// Multiplies the first operand by the second, storing the result in the
    /// first.
    static func *= (_: inout Self, _: Self)

    /// Returns the remainder of dividing the first operand by the second.
    static func % (_: Self, _: Self) -> Self

    /// Divides the first operand by the second, storing the remainder in the
    /// first.
    static func %= (_: inout Self, _: Self)
}

/// A small extension upon Arithmetic to support negative values.
protocol SignedArithmetic: Arithmetic {
    /// Returns the negated version of the given value.
    static prefix func - (_: Self) -> Self
}

// MARK: Integer Types
// Super simple, just declaring conformance

extension UInt: Arithmetic {}
extension UInt8: Arithmetic {}
extension UInt16: Arithmetic {}
extension UInt32: Arithmetic {}
extension UInt64: Arithmetic {}
extension Int: SignedArithmetic {}
extension Int8: SignedArithmetic {}
extension Int16: SignedArithmetic {}
extension Int32: SignedArithmetic {}
extension Int64: SignedArithmetic {}

// MARK: Floating Point Types
// The FloatingPoint doesn't define a remainder operator, but provides the
// functionality in a method.

extension Float: SignedArithmetic {
    /// Returns the remainder of dividing the first operand by the second.
    public static func % (_ a: Float, _ b: Float) -> Float {
        return a.truncatingRemainder(dividingBy: b)
    }

    /// Divides the first operand by the second, storing the remainder in the
    /// first.
    public static func %= (_ a: inout Float, _ b: Float) {
        a = a.truncatingRemainder(dividingBy: b)
    }
}

#if arch(i386) || arch(x86_64)
extension Float80: SignedArithmetic {
    /// Returns the remainder of dividing the first operand by the second.
    public static func % (_ a: Float80, _ b: Float80) -> Float80 {
        return a.truncatingRemainder(dividingBy: b)
    }

    /// Divides the first operand by the second, storing the remainder in the
    /// first.
    public static func %= (_ a: inout Float80, _ b: Float80) {
        a = a.truncatingRemainder(dividingBy: b)
    }
}
#endif

extension Double: SignedArithmetic {
    /// Returns the remainder of dividing the first operand by the second.
    public static func % (_ a: Double, _ b: Double) -> Double {
        return a.truncatingRemainder(dividingBy: b)
    }

    /// Divides the first operand by the second, storing the remainder in the
    /// first.
    public static func %= (_ a: inout Double, _ b: Double) {
        a = a.truncatingRemainder(dividingBy: b)
    }
}
