import RealModule

// Real covers basic operations on floating point values (and complex), while
// BinaryInteger requires it's conforming types to provide division operators
// (Numeric only requires multiplication).
public typealias Number = Real & BinaryInteger
