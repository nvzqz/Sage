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

/// A lookup table of all king attack bitboards.
internal let _kingAttackTable: [Bitboard] = Square.all.map { square in
    return Bitboard(square: square)._kingAttacks()
}

/// A lookup table of all knight attack bitboards.
internal let _knightAttackTable: [Bitboard] = Square.all.map { square in
    return Bitboard(square: square)._knightAttacks()
}

/// Mask for bits not in File A.
private let _notFileA: Bitboard = 0xfefefefefefefefe

/// Mask for bits not in Files A and B.
private let _notFileAB: Bitboard = 0xfcfcfcfcfcfcfcfc

/// Mask for bits not in File H.
private let _notFileH: Bitboard = 0x7f7f7f7f7f7f7f7f

/// Mask for bits not in Files G and H.
private let _notFileGH: Bitboard = 0x3f3f3f3f3f3f3f3f

/// A board of 64 bits.
public struct Bitboard: BitwiseOperationsType, RawRepresentable, Equatable, Hashable {

    /// A bitboard shift direction.
    public enum ShiftDirection {

        /// North direction.
        case North

        /// South direction.
        case South

        /// East direction.
        case East

        /// West direction.
        case West

        /// Northeast direction.
        case Northeast

        /// Southeast direction.
        case Southeast

        /// Northwest direction.
        case Northwest

        /// Southwest direction.
        case Southwest

        /// Returns `value` shifted by an amount corresponding to `self`.
        private func _bitShift(of value: UInt64) -> UInt64 {
            switch self {
            case .North:     return value << 8
            case .South:     return value >> 8
            case .East:      return value << 1
            case .West:      return value >> 1
            case .Northeast: return value << 9
            case .Southwest: return value >> 9
            case .Northwest: return value << 7
            case .Southeast: return value >> 7
            }
        }

        /// Returns the good files for `self` in fill.
        private func _goodFiles() -> UInt64 {
            switch self {
            case .East, .Northeast, .Southeast:
                return _notFileA.rawValue
            case .West, .Northwest, .Southwest:
                return _notFileH.rawValue
            default:
                return ~0
            }
        }

    }

    /// The empty bitset.
    public static var allZeros: Bitboard {
        return Bitboard(rawValue: 0)
    }

    /// The edges of a board.
    public static let edges: Bitboard = 0xff818181818181ff

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

    /// The square of the least significant bit of `self`.
    public var lsbSquare: Square? {
        return lsbIndex.flatMap({ Square(rawValue: $0) })
    }

    /// The occupied squares.
    public var occupiedSquares: [Square] {
        var result: [Square] = []
        var board = self
        while let square = board.popLSBSquare() {
            result.append(square)
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

    /// Returns the pawn pushes available for `color` in `self`.
    @warn_unused_result
    internal func _pawnPushes(for color: Color, empty: Bitboard) -> Bitboard {
        if color.isWhite {
            return shifted(toward: .North) & empty
        } else {
            return shifted(toward: .South) & empty
        }
    }

    /// Returns the attacks available to the pawns for `color` in `self`.
    @warn_unused_result
    internal func _pawnAttacks(for color: Color) -> Bitboard {
        if color.isWhite {
            return shifted(toward: .Northeast) | shifted(toward: .Northwest)
        } else {
            return shifted(toward: .Southeast) | shifted(toward: .Southwest)
        }
    }

    /// Returns the attacks available to the knight in `self`.
    @warn_unused_result
    internal func _knightAttacks() -> Bitboard {
        let x = self
        return (((x << 17) | (x >> 15)) & _notFileA)
            |  (((x << 10) | (x >> 06)) & _notFileAB)
            |  (((x << 15) | (x >> 17)) & _notFileH)
            |  (((x << 06) | (x >> 10)) & _notFileGH)
    }

    /// Returns the attacks available to the bishop in `self`.
    @warn_unused_result
    internal func _bishopAttacks(blockers bitboard: Bitboard = 0) -> Bitboard {
        return ~self
            & (filled(toward: .Northeast, blockers: bitboard)
            |  filled(toward: .Northwest, blockers: bitboard)
            |  filled(toward: .Southeast, blockers: bitboard)
            |  filled(toward: .Southwest, blockers: bitboard))
    }

    /// Returns the attacks available to the rook in `self`.
    @warn_unused_result
    internal func _rookAttacks(blockers bitboard: Bitboard = 0) -> Bitboard {
        return ~self
            & (filled(toward: .North, blockers: bitboard)
            |  filled(toward: .South, blockers: bitboard)
            |  filled(toward: .East,  blockers: bitboard)
            |  filled(toward: .West,  blockers: bitboard))
    }

    /// Returns the attacks available to the queen in `self`.
    @warn_unused_result
    internal func _queenAttacks(blockers bitboard: Bitboard = 0) -> Bitboard {
        return _rookAttacks(blockers: bitboard) | _bishopAttacks(blockers: bitboard)
    }

    /// Returns the attacks available to the king in `self`.
    @warn_unused_result
    internal func _kingAttacks() -> Bitboard {
        let attacks = shifted(toward: .East) | shifted(toward: .West)
        let bitboard = self | attacks
        return attacks
            | bitboard.shifted(toward: .North)
            | bitboard.shifted(toward: .South)
    }

    /// Returns the attacks available to `piece` in `self`.
    @warn_unused_result
    internal func _attacks(for piece: Piece, blockers: Bitboard = 0) -> Bitboard {
        switch piece {
        case .Pawn(let color):
            return _pawnAttacks(for: color)
        case .Knight:
            return _knightAttacks()
        case .Bishop:
            return _bishopAttacks(blockers: blockers)
        case .Rook:
            return _rookAttacks(blockers: blockers)
        case .Queen:
            return _queenAttacks(blockers: blockers)
        case .King:
            return _kingAttacks()
        }
    }

    /// Returns `self` flipped horizontally.
    @warn_unused_result(mutable_variant="flipHorizontally")
    public func flippedHorizontally() -> Bitboard {
        let x = 0x5555555555555555 as Bitboard
        let y = 0x3333333333333333 as Bitboard
        let z = 0x0F0F0F0F0F0F0F0F as Bitboard
        var n = self
        n = ((n >> 1) & x) | ((n & x) << 1)
        n = ((n >> 2) & y) | ((n & y) << 2)
        n = ((n >> 4) & z) | ((n & z) << 4)
        return n
    }

    /// Flips `self` horizontally.
    public mutating func flipHorizontally() {
        self = flippedHorizontally()
    }

    /// Returns `self` flipped vertically.
    @warn_unused_result(mutable_variant="flipVertically")
    public func flippedVertically() -> Bitboard {
        let x = 0x00FF00FF00FF00FF as Bitboard
        let y = 0x0000FFFF0000FFFF as Bitboard
        var n = self
        n = ((n >>  8) & x) | ((n & x) <<  8)
        n = ((n >> 16) & y) | ((n & y) << 16)
        n =  (n >> 32)      |       (n << 32)
        return n
    }

    /// Flips `self` vertically.
    public mutating func flipVertically() {
        self = flippedVertically()
    }

    /// Returns the bits of `self` shifted once toward `direction`.
    @warn_unused_result(mutable_variant="shift")
    public func shifted(toward direction: ShiftDirection) -> Bitboard {
        switch direction {
        case .North:     return  self << 8
        case .South:     return  self >> 8
        case .East:      return (self << 1) & _notFileA
        case .Northeast: return (self << 9) & _notFileA
        case .Southeast: return (self >> 7) & _notFileA
        case .West:      return (self >> 1) & _notFileH
        case .Southwest: return (self >> 9) & _notFileH
        case .Northwest: return (self << 7) & _notFileH
        }
    }

    /// Shifts the bits of `self` once toward `direction`.
    public mutating func shift(toward direction: ShiftDirection) {
        self = shifted(toward: direction)
    }

    /// Returns the bits of `self` filled toward `direction` blocked by `blockers`.
    @warn_unused_result(mutable_variant="fill")
    public func filled(toward direction: ShiftDirection, blockers: Bitboard = 0) -> Bitboard {
        let g = direction._goodFiles()
        let e = ~blockers.rawValue
        var x = rawValue
        for _ in 0 ..< 7 {
            x |= (e & direction._bitShift(of: x)) & g
        }
        return Bitboard(rawValue: x)
    }

    /// Fills the bits of `self` toward `direction` blocked by `blockers`.
    public mutating func fill(toward direction: ShiftDirection, blockers: Bitboard = 0) {
        self = filled(toward: direction, blockers: blockers)
    }

    /// Removes the least significant bit and returns its index, if any.
    public mutating func popLSB() -> Int? {
        let lsb = self.lsb
        rawValue -= lsb.rawValue
        return lsb.lsbIndex
    }

    /// Removes the least significant bit and returns its square, if any.
    public mutating func popLSBSquare() -> Square? {
        return popLSB().flatMap({ Square(rawValue: $0) })
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

/// Returns the bits of `lhs` shifted right by `rhs`.
@warn_unused_result
public func >> (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue >> rhs.rawValue)
}

/// Shifts the bits of `lhs` right by `rhs`.
public func >>= (inout lhs: Bitboard, rhs: Bitboard) {
    lhs.rawValue >>= rhs.rawValue
}

/// Returns the bits of `lhs` shifted left by `rhs`.
@warn_unused_result
public func << (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue << rhs.rawValue)
}

/// Shifts the bits of `lhs` left by `rhs`.
public func <<= (inout lhs: Bitboard, rhs: Bitboard) {
    lhs.rawValue <<= rhs.rawValue
}
