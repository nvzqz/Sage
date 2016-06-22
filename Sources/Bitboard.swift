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

/// A lookup table of least significant bit indices.
private let _lsbTable = [00, 01, 48, 02, 57, 49, 28, 03, 61, 58, 50,
                         42, 38, 29, 17, 04, 62, 55, 59, 36, 53, 51,
                         43, 22, 45, 39, 33, 30, 24, 18, 12, 05, 63,
                         47, 56, 27, 60, 41, 37, 16, 54, 35, 52, 21,
                         44, 32, 23, 11, 46, 26, 40, 15, 34, 20, 31,
                         10, 25, 14, 19, 09, 13, 08, 07, 06]

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

    /// The number of bits set in `self`.
    public var count: Int {
        var n = rawValue
        n = n - ((n >> 1) & 0x5555555555555555)
        n = (n & 0x3333333333333333) + ((n >> 2) & 0x3333333333333333)
        return Int((((n + (n >> 4)) & 0xF0F0F0F0F0F0F0F) &* 0x101010101010101) >> 56)
    }

    /// `true` if `self` is empty.
    public var isEmpty: Bool {
        return self == 0
    }

    /// The least significant bit.
    public var lsb: Bitboard {
        return Bitboard(rawValue: rawValue & (0 &- rawValue))
    }

    /// The least significant bit index of `self`.
    public var lsbIndex: Int? {
        guard !self.isEmpty else {
            return nil
        }
        return _lsbTable[Int((lsb.rawValue &* 0x03f79d71b4cb0a89) >> 58)]
    }

    /// The occupied squares.
    public var occupiedSquares: [Square] {
        var result: [Square] = []
        var board = self
        while let index = board.popLSB() {
            result.append(Square(rawValue: index)!)
        }
        return result
    }

    /// Convert from a raw value of `UInt64`.
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    /// Create an empty bitboard.
    public init() {
        rawValue = 0
    }

    /// Create a bitboard from `squares`.
    public init<S: SequenceType where S.Generator.Element == Square>(squares: S) {
        rawValue = squares.reduce(0) { $0 | (1 << UInt64($1.rawValue)) }
    }

    /// Create a bitboard from `locations`.
    public init<S: SequenceType where S.Generator.Element == Location>(locations: S) {
        self.init(squares: locations.map(Square.init(location:)))
    }

    /// Create a bitboard mask for `file`.
    public init(file: File) {
        switch file {
        case .A: rawValue = 0x0101010101010101
        case .B: rawValue = 0x0202020202020202
        case .C: rawValue = 0x0404040404040404
        case .D: rawValue = 0x0808080808080808
        case .E: rawValue = 0x1010101010101010
        case .F: rawValue = 0x2020202020202020
        case .G: rawValue = 0x4040404040404040
        case .H: rawValue = 0x8080808080808080
        }
    }

    /// Create a bitboard mask for `rank`.
    public init(rank: Rank) {
        rawValue = 0xFF << (UInt64(rank.index) * 8)
    }

    /// Create a bitboard mask for `square`.
    public init(square: Square) {
        rawValue = 1 << UInt64(square.rawValue)
    }

    /// The `Bool` value for the bit at `square`.
    public subscript(square: Square) -> Bool {
        get {
            return 1 << UInt64(square.rawValue) & rawValue != 0
        }
        set {
            let bit = Bitboard(square: square)
            if newValue {
                rawValue |= bit.rawValue
            } else {
                rawValue &= ~bit.rawValue
            }
        }
    }

    /// The `Bool` value for the bit at `location`.
    public subscript(location: Location) -> Bool {
        get {
            return self[Square(location: location)]
        }
        set {
            self[Square(location: location)] = newValue
        }
    }

    /// Returns `self` flipped horizontally.
    @warn_unused_result(mutable_variant="flipHorizontally")
    public func flippedHorizontally() -> Bitboard {
        let x = 0x5555555555555555 as UInt64
        let y = 0x3333333333333333 as UInt64
        let z = 0x0F0F0F0F0F0F0F0F as UInt64
        var n = rawValue
        n = ((n >> 1) & x) | ((n & x) << 1)
        n = ((n >> 2) & y) | ((n & y) << 2)
        n = ((n >> 4) & z) | ((n & z) << 4)
        return Bitboard(rawValue: n)
    }

    /// Flips `self` horizontally.
    public mutating func flipHorizontally() {
        self = flippedHorizontally()
    }

    /// Returns `self` flipped vertically.
    @warn_unused_result(mutable_variant="flipVertically")
    public func flippedVertically() -> Bitboard {
        let x = 0x00FF00FF00FF00FF as UInt64
        let y = 0x0000FFFF0000FFFF as UInt64
        var n = rawValue
        n = ((n >>  8) & x) | ((n & x) <<  8)
        n = ((n >> 16) & y) | ((n & y) << 16)
        n =  (n >> 32)      |       (n << 32)
        return Bitboard(rawValue: n)
    }

    /// Flips `self` vertically.
    public mutating func flipVertically() {
        self = flippedVertically()
    }

    /// Removes the least significant bit and returns its index, if any.
    public mutating func popLSB() -> Int? {
        let lsb = self.lsb
        rawValue -= lsb.rawValue
        return lsb.lsbIndex
    }

    /// Returns the ranks of `self` as eight 8-bit integers.
    @warn_unused_result
    public func ranks() -> [UInt8] {
        return (0 ..< 8).map { UInt8((rawValue >> ($0 * 8)) % 256) }
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
