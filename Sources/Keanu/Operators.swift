// The SIMD protocol defines various "dot" operators for point-wise
// operations on SIMD types. Because + is already being used for
// concatenation of sequences, I'm using .+ for point-wise addition.
// To keep the pattern the same across the other operators, I've added
// corresponding operators for subtraction and multiplication.

// For the time being I'm skipping division, as it would mean
// implementing VectorOperations on FloatingPoint and BinaryInteger
// individually as division is defined on those types and not Numeric
// (which is what I've implemented VEctorOperations on so far).

infix operator .+: AdditionPrecedence
infix operator .-: AdditionPrecedence
infix operator .*: MultiplicationPrecedence
infix operator **: MultiplicationPrecedence
