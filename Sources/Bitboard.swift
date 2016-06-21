//
//  Bitboard.swift
//  Fischer
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Nikolai Vazquez
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/// A board of 64 bits.
public struct Bitboard: BitwiseOperationsType, RawRepresentable, Equatable, Hashable {

    /// The empty bitset.
    public static var allZeros: Bitboard {
        return Bitboard(rawValue: 0)
    }

    /// The corresponding value of the "raw" type.
    ///
    /// `Self(rawValue: self.rawValue)!` is equivalent to `self`.
    public var rawValue: UInt64

    /// The hash value.
    public var hashValue: Int {
        return rawValue.hashValue
    }

    /// Convert from a raw value of `UInt64`.
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    /// Create an empty bitboard.
    public init() {
        rawValue = 0
    }

}

extension Bitboard: IntegerLiteralConvertible {
    /// Create an instance initialized to `value`.
    public init(integerLiteral value: UInt64) {
        rawValue = value
    }
}

/// Returns the intersection of bits set in `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func & (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue & rhs.rawValue)
}

/// Returns the union of bits set in `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func | (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue | rhs.rawValue)
}

/// Returns the bits that are set in exactly one of `lhs` and `rhs`.
///
/// - Complexity: O(1).
@warn_unused_result
public func ^ (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue ^ rhs.rawValue)
}

/// Returns `x ^ ~Self.allZeros`.
///
/// - Complexity: O(1).
@warn_unused_result
public prefix func ~ (x: Bitboard) -> Bitboard {
    return Bitboard(rawValue: ~x.rawValue)
}
