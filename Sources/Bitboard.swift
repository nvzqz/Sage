//
//  Bitboard.swift
//  Sage
//
//  Copyright 2016 Nikolai Vazquez
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// A lookup table of least significant bit indices.
private let _lsbTable: ContiguousArray<Int> = [00, 01, 48, 02, 57, 49, 28, 03, 61, 58, 50,
                                               42, 38, 29, 17, 04, 62, 55, 59, 36, 53, 51,
                                               43, 22, 45, 39, 33, 30, 24, 18, 12, 05, 63,
                                               47, 56, 27, 60, 41, 37, 16, 54, 35, 52, 21,
                                               44, 32, 23, 11, 46, 26, 40, 15, 34, 20, 31,
                                               10, 25, 14, 19, 09, 13, 08, 07, 06]

/// A lookup table of bitboards for all squares.
private let _bitboardTable = ContiguousArray((0 ..< 64).map { Bitboard(rawValue: 1 << $0) })

/// Returns the index of the lsb value.
private func _index(lsb value: Bitboard) -> Int? {
    guard value != 0 else {
        return nil
    }
    return _lsbTable[Int((value.rawValue &* 0x03f79d71b4cb0a89) >> 58)]
}

/// Returns the pawn attack table for `color`.
internal func _pawnAttackTable(for color: Color) -> ContiguousArray<Bitboard> {
    if color.isWhite {
        return _whitePawnAttackTable
    } else {
        return _blackPawnAttackTable
    }
}

/// A lookup table of all white pawn attack bitboards.
internal let _whitePawnAttackTable = ContiguousArray(Square.all.map { square in
    return Bitboard(square: square)._pawnAttacks(for: ._white)
})

/// A lookup table of all black pawn attack bitboards.
internal let _blackPawnAttackTable = ContiguousArray(Square.all.map { square in
    return Bitboard(square: square)._pawnAttacks(for: ._black)
})

/// A lookup table of all king attack bitboards.
internal let _kingAttackTable = ContiguousArray(Square.all.map { square in
    return Bitboard(square: square)._kingAttacks()
})

/// A lookup table of all knight attack bitboards.
internal let _knightAttackTable = ContiguousArray(Square.all.map { square in
    return Bitboard(square: square)._knightAttacks()
})

/// Mask for bits not in File A.
private let _notFileA: Bitboard = 0xfefefefefefefefe

/// Mask for bits not in Files A and B.
private let _notFileAB: Bitboard = 0xfcfcfcfcfcfcfcfc

/// Mask for bits not in File H.
private let _notFileH: Bitboard = 0x7f7f7f7f7f7f7f7f

/// Mask for bits not in Files G and H.
private let _notFileGH: Bitboard = 0x3f3f3f3f3f3f3f3f

/// A bitmap of sixty-four bits suitable for storing squares for various pieces.
///
/// The first bit refers to `Square.A1` the last (64th) bit refers to `Square.H8`.
///
/// Due to their compact nature, bitboards can store information such as positions in memory very efficiently. Bitboards
/// can also be used to answer questions about the state of a `Board` quickly with very few operations.
///
/// Bitboards used internally within `Board` to store positions for all twelve cases of `Piece`.
///
/// - seealso: [Bitboard (Wikipedia)](https://en.wikipedia.org/wiki/Bitboard),
///            [Bitboards (Chess Programming Wiki)](https://chessprogramming.wikispaces.com/Bitboards)
public struct Bitboard: RawRepresentable, Hashable, CustomStringConvertible {

    /// A bitboard shift direction.
    public enum ShiftDirection {

        #if swift(>=3)

        /// North direction.
        case north

        /// South direction.
        case south

        /// East direction.
        case east

        /// West direction.
        case west

        /// Northeast direction.
        case northeast

        /// Southeast direction.
        case southeast

        /// Northwest direction.
        case northwest

        /// Southwest direction.
        case southwest

        /// North regardless of Swift version.
        internal static let _north = ShiftDirection.north

        /// South regardless of Swift version.
        internal static let _south = ShiftDirection.south

        /// East regardless of Swift version.
        internal static let _east = ShiftDirection.east

        /// West regardless of Swift version.
        internal static let _west = ShiftDirection.west

        /// Northeast regardless of Swift version.
        internal static let _northeast = ShiftDirection.northeast

        /// Southeast regardless of Swift version.
        internal static let _southeast = ShiftDirection.southeast

        /// Northwest regardless of Swift version.
        internal static let _northwest = ShiftDirection.northwest

        /// Southwest regardless of Swift version.
        internal static let _southwest = ShiftDirection.southwest

        #else

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

        /// North regardless of Swift version.
        internal static let _north = ShiftDirection.North

        /// South regardless of Swift version.
        internal static let _south = ShiftDirection.South

        /// East regardless of Swift version.
        internal static let _east = ShiftDirection.East

        /// West regardless of Swift version.
        internal static let _west = ShiftDirection.West

        /// Northeast regardless of Swift version.
        internal static let _northeast = ShiftDirection.Northeast

        /// Southeast regardless of Swift version.
        internal static let _southeast = ShiftDirection.Southeast

        /// Northwest regardless of Swift version.
        internal static let _northwest = ShiftDirection.Northwest

        /// Southwest regardless of Swift version.
        internal static let _southwest = ShiftDirection.Southwest

        #endif

    }

    /// An iterator for `Bitboard` used as a base for both `Iterator` and `Generator`.
    private struct _MutualIterator {

        var _bitboard: Bitboard

        init(_ bitboard: Bitboard) {
            self._bitboard = bitboard
        }

        mutating func next() -> Square? {
            return _bitboard.popLSBSquare()
        }

    }

    #if swift(>=3)

    /// An iterator for the squares of a `Bitboard`.
    public struct Iterator: IteratorProtocol {

        private var _base: _MutualIterator

        /// Advances and returns the next element of the underlying sequence, or
        /// `nil` if no next element exists.
        public mutating func next() -> Square? {
            return _base.next()
        }

    }

    #else

    /// A generator for the squares of a `Bitboard`.
    public struct Generator: GeneratorType {

        private var _base: _MutualIterator

        /// Advance to the next element and return it, or `nil` if no next element exists.
        public mutating func next() -> Square? {
            return _base.next()
        }

    }

    #endif

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

    /// A textual representation of `self`.
    public var description: String {
        let num = String(rawValue, radix: 16)
        #if swift(>=3)
            let str = repeatElement("0", count: 16 - num.characters.count).joined(separator: "")
        #else
            let str = Repeat(count: 16 - num.characters.count, repeatedValue: "0").joinWithSeparator("")
        #endif
        return "Bitboard(0x\(str + num))"
    }

    /// The hash value.
    public var hashValue: Int {
        return rawValue.hashValue
    }

    /// An ASCII art representation of `self`.
    ///
    /// The ASCII representation for the starting board's bitboard:
    ///
    /// ```
    ///   +-----------------+
    /// 8 | 1 1 1 1 1 1 1 1 |
    /// 7 | 1 1 1 1 1 1 1 1 |
    /// 6 | . . . . . . . . |
    /// 5 | . . . . . . . . |
    /// 4 | . . . . . . . . |
    /// 3 | . . . . . . . . |
    /// 2 | 1 1 1 1 1 1 1 1 |
    /// 1 | 1 1 1 1 1 1 1 1 |
    ///   +-----------------+
    ///     a b c d e f g h
    /// ```
    public var ascii: String {
        let edge = "  +-----------------+\n"
        var result = edge
        #if swift(>=3)
            let ranks = Rank.all.reversed()
        #else
            let ranks = Rank.all.reverse()
        #endif
        for rank in ranks {
            let strings = File.all.map({ file in self[(file, rank)] ? "1" : "." })
            #if swift(>=3)
                let str = strings.joined(separator: " ")
            #else
                let str = strings.joinWithSeparator(" ")
            #endif
            result += "\(rank) | \(str) |\n"
        }
        result += "\(edge)    a b c d e f g h  "
        return result
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

    /// The index for the least significant bit of `self`.
    public var lsbIndex: Int? {
        return _index(lsb: lsb)
    }

    /// The square for the least significant bit of `self`.
    public var lsbSquare: Square? {
        return lsbIndex.flatMap({ Square(rawValue: $0) })
    }

    /// Convert from a raw value of `UInt64`.
    public init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    /// Create an empty bitboard.
    public init() {
        rawValue = 0
    }

    /// Create a starting bitboard for `piece`.
    public init(startFor piece: Piece) {
        #if swift(>=3)
            switch piece {
            case .pawn(.white):   self = 0x000000000000FF00
            case .knight(.white): self = 0x0000000000000042
            case .bishop(.white): self = 0x0000000000000024
            case .rook(.white):   self = 0x0000000000000081
            case .queen(.white):  self = 0x0000000000000008
            case .king(.white):   self = 0x0000000000000010
            case .pawn(.black):   self = 0x00FF000000000000
            case .knight(.black): self = 0x4200000000000000
            case .bishop(.black): self = 0x2400000000000000
            case .rook(.black):   self = 0x8100000000000000
            case .queen(.black):  self = 0x0800000000000000
            case .king(.black):   self = 0x1000000000000000
            }
        #else
            switch piece {
            case .Pawn(.White):   self = 0x000000000000FF00
            case .Knight(.White): self = 0x0000000000000042
            case .Bishop(.White): self = 0x0000000000000024
            case .Rook(.White):   self = 0x0000000000000081
            case .Queen(.White):  self = 0x0000000000000008
            case .King(.White):   self = 0x0000000000000010
            case .Pawn(.Black):   self = 0x00FF000000000000
            case .Knight(.Black): self = 0x4200000000000000
            case .Bishop(.Black): self = 0x2400000000000000
            case .Rook(.Black):   self = 0x8100000000000000
            case .Queen(.Black):  self = 0x0800000000000000
            case .King(.Black):   self = 0x1000000000000000
            }
        #endif
    }

    #if swift(>=3)

    /// Create a bitboard from `squares`.
    public init<S: Sequence where S.Iterator.Element == Square>(squares: S) {
        rawValue = squares.reduce(0) { $0 | (1 << UInt64($1.rawValue)) }
    }

    /// Create a bitboard from `locations`.
    public init<S: Sequence where S.Iterator.Element == Location>(locations: S) {
        self.init(squares: locations.map(Square.init(location:)))
    }

    #else

    /// Create a bitboard from `squares`.
    public init<S: SequenceType where S.Generator.Element == Square>(squares: S) {
        rawValue = squares.reduce(0) { $0 | (1 << UInt64($1.rawValue)) }
    }

    /// Create a bitboard from `locations`.
    public init<S: SequenceType where S.Generator.Element == Location>(locations: S) {
        self.init(squares: locations.map(Square.init(location:)))
    }

    #endif

    /// Create a bitboard from the start and end of `move`.
    public init(move: Move) {
        self.init(squares: [move.start, move.end])
    }

    /// Create a bitboard mask for `file`.
    public init(file: File) {
        #if swift(>=3)
            switch file {
            case .a: rawValue = 0x0101010101010101
            case .b: rawValue = 0x0202020202020202
            case .c: rawValue = 0x0404040404040404
            case .d: rawValue = 0x0808080808080808
            case .e: rawValue = 0x1010101010101010
            case .f: rawValue = 0x2020202020202020
            case .g: rawValue = 0x4040404040404040
            case .h: rawValue = 0x8080808080808080
            }
        #else
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
        #endif
    }

    /// Create a bitboard mask for `rank`.
    public init(rank: Rank) {
        rawValue = 0xFF << (UInt64(rank.index) * 8)
    }

    /// Create a bitboard mask for `square`.
    ///
    /// - complexity: O(1).
    public init(square: Square) {
        self = _bitboardTable[square.rawValue]
    }

    /// The `Bool` value for the bit at `square`.
    ///
    /// - complexity: O(1).
    public subscript(square: Square) -> Bool {
        get {
            return intersects(_bitboardTable[square.rawValue])
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
    ///
    /// - complexity: O(1).
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
        return (color.isWhite ? shifted(toward: ._north) : shifted(toward: ._south)) & empty
    }

    /// Returns the attacks available to the pawns for `color` in `self`.
    @warn_unused_result
    internal func _pawnAttacks(for color: Color) -> Bitboard {
        if color.isWhite {
            return shifted(toward: ._northeast) | shifted(toward: ._northwest)
        } else {
            return shifted(toward: ._southeast) | shifted(toward: ._southwest)
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
    internal func _bishopAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return filled(toward: ._northeast, stoppers: bitboard).shifted(toward: ._northeast)
            |  filled(toward: ._northwest, stoppers: bitboard).shifted(toward: ._northwest)
            |  filled(toward: ._southeast, stoppers: bitboard).shifted(toward: ._southeast)
            |  filled(toward: ._southwest, stoppers: bitboard).shifted(toward: ._southwest)
    }

    /// Returns the attacks available to the rook in `self`.
    @warn_unused_result
    internal func _rookAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return filled(toward: ._north, stoppers: bitboard).shifted(toward: ._north)
            |  filled(toward: ._south, stoppers: bitboard).shifted(toward: ._south)
            |  filled(toward: ._east,  stoppers: bitboard).shifted(toward: ._east)
            |  filled(toward: ._west,  stoppers: bitboard).shifted(toward: ._west)
    }

    /// Returns the attacks available to the queen in `self`.
    @warn_unused_result
    internal func _queenAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return _rookAttacks(stoppers: bitboard) | _bishopAttacks(stoppers: bitboard)
    }

    /// Returns the attacks available to the king in `self`.
    @warn_unused_result
    internal func _kingAttacks() -> Bitboard {
        let attacks = shifted(toward: ._east) | shifted(toward: ._west)
        let bitboard = self | attacks
        return attacks
            | bitboard.shifted(toward: ._north)
            | bitboard.shifted(toward: ._south)
    }

    /// Returns the attacks available to `piece` in `self`.
    internal func _attacks(for piece: Piece, stoppers: Bitboard = 0) -> Bitboard {
        #if swift(>=3)
            switch piece {
            case .pawn(let color):
                return _pawnAttacks(for: color)
            case .knight:
                return _knightAttacks()
            case .bishop:
                return _bishopAttacks(stoppers: stoppers)
            case .rook:
                return _rookAttacks(stoppers: stoppers)
            case .queen:
                return _queenAttacks(stoppers: stoppers)
            case .king:
                return _kingAttacks()
            }
        #else
            switch piece {
            case .Pawn(let color):
                return _pawnAttacks(for: color)
            case .Knight:
                return _knightAttacks()
            case .Bishop:
                return _bishopAttacks(stoppers: stoppers)
            case .Rook:
                return _rookAttacks(stoppers: stoppers)
            case .Queen:
                return _queenAttacks(stoppers: stoppers)
            case .King:
                return _kingAttacks()
            }
        #endif
    }

    /// Returns `true` if `self` intersects `other`.
    @warn_unused_result
    public func intersects(_ other: Bitboard) -> Bool {
        return rawValue & other.rawValue != 0
    }

    /// Returns `self` flipped horizontally.
    @warn_unused_result
    private func _flippedHorizontally() -> Bitboard {
        let x = 0x5555555555555555 as Bitboard
        let y = 0x3333333333333333 as Bitboard
        let z = 0x0F0F0F0F0F0F0F0F as Bitboard
        var n = self
        n = ((n >> 1) & x) | ((n & x) << 1)
        n = ((n >> 2) & y) | ((n & y) << 2)
        n = ((n >> 4) & z) | ((n & z) << 4)
        return n
    }

    /// Returns `self` flipped vertically.
    @warn_unused_result
    private func _flippedVertically() -> Bitboard {
        let x = 0x00FF00FF00FF00FF as Bitboard
        let y = 0x0000FFFF0000FFFF as Bitboard
        var n = self
        n = ((n >>  8) & x) | ((n & x) <<  8)
        n = ((n >> 16) & y) | ((n & y) << 16)
        n =  (n >> 32)      |       (n << 32)
        return n
    }

    /// Returns the bits of `self` filled toward `direction` stopped by `stoppers`.
    @warn_unused_result
    private func _filled(toward direction: ShiftDirection, stoppers: Bitboard) -> Bitboard {
        let empty = ~stoppers
        var bitboard = self
        for _ in 0 ..< 7 {
            bitboard |= empty & bitboard.shifted(toward: direction)
        }
        return bitboard
    }

    #if swift(>=3)

    /// Returns `self` flipped horizontally.
    @warn_unused_result(mutable_variant:"flipHorizontally")
    public func flippedHorizontally() -> Bitboard {
        return _flippedHorizontally()
    }

    /// Returns `self` flipped vertically.
    @warn_unused_result(mutable_variant:"flipVertically")
    public func flippedVertically() -> Bitboard {
        return _flippedVertically()
    }

    /// Returns the bits of `self` shifted once toward `direction`.
    @warn_unused_result(mutable_variant:"shift")
    public func shifted(toward direction: ShiftDirection) -> Bitboard {
        switch direction {
        case .north:     return  self << 8
        case .south:     return  self >> 8
        case .east:      return (self << 1) & _notFileA
        case .northeast: return (self << 9) & _notFileA
        case .southeast: return (self >> 7) & _notFileA
        case .west:      return (self >> 1) & _notFileH
        case .southwest: return (self >> 9) & _notFileH
        case .northwest: return (self << 7) & _notFileH
        }
    }

    /// Returns the bits of `self` filled toward `direction` stopped by `stoppers`.
    @warn_unused_result(mutable_variant:"fill")
    public func filled(toward direction: ShiftDirection, stoppers: Bitboard = 0) -> Bitboard {
        return _filled(toward: direction, stoppers: stoppers)
    }

    #else

    /// Returns `self` flipped horizontally.
    @warn_unused_result(mutable_variant="flipHorizontally")
    public func flippedHorizontally() -> Bitboard {
        return _flippedHorizontally()
    }

    /// Returns `self` flipped vertically.
    @warn_unused_result(mutable_variant="flipVertically")
    public func flippedVertically() -> Bitboard {
        return _flippedVertically()
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

    /// Returns the bits of `self` filled toward `direction` stopped by `stoppers`.
    @warn_unused_result(mutable_variant="fill")
    public func filled(toward direction: ShiftDirection, stoppers: Bitboard = 0) -> Bitboard {
        return _filled(toward: direction, stoppers: stoppers)
    }

    #endif

    /// Flips `self` horizontally.
    public mutating func flipHorizontally() {
        self = flippedHorizontally()
    }

    /// Flips `self` vertically.
    public mutating func flipVertically() {
        self = flippedVertically()
    }

    /// Shifts the bits of `self` once toward `direction`.
    public mutating func shift(toward direction: ShiftDirection) {
        self = shifted(toward: direction)
    }

    /// Fills the bits of `self` toward `direction` stopped by `stoppers`.
    public mutating func fill(toward direction: ShiftDirection, stoppers: Bitboard = 0) {
        self = filled(toward: direction, stoppers: stoppers)
    }

    /// Swaps the bits between the two squares.
    public mutating func swap(_ first: Square, _ second: Square) {
        (self[first], self[second]) = (self[second], self[first])
    }

    /// Removes the least significant bit and returns it.
    public mutating func popLSB() -> Bitboard {
        let lsb = self.lsb
        rawValue -= lsb.rawValue
        return lsb
    }

    /// Removes the least significant bit and returns its index, if any.
    public mutating func popLSBIndex() -> Int? {
        return _index(lsb: popLSB())
    }

    /// Removes the least significant bit and returns its square, if any.
    public mutating func popLSBSquare() -> Square? {
        return popLSBIndex().flatMap({ Square(rawValue: $0) })
    }

    /// Returns the ranks of `self` as eight 8-bit integers.
    @warn_unused_result
    public func ranks() -> [UInt8] {
        return (0 ..< 8).map { UInt8((rawValue >> ($0 * 8)) & 255) }
    }

}

#if swift(>=3)

extension Bitboard: Sequence, BitwiseOperations {

    /// A value less than or equal to the number of elements in
    /// the sequence, calculated nondestructively.
    ///
    /// - complexity: O(1).
    public var underestimatedCount: Int {
        return count
    }

    /// Returns an iterator over the squares of the board.
    public func makeIterator() -> Iterator {
        return Iterator(_base: _MutualIterator(self))
    }

}

#else

extension Bitboard: SequenceType, BitwiseOperationsType {

    /// Returns a value less than or equal to the number of elements in
    /// `self`, **nondestructively**.
    ///
    /// - complexity: O(1).
    public func underestimateCount() -> Int {
        return count
    }

    /// Returns a generator over the squares of the board.
    ///
    /// - complexity: O(1).
    public func generate() -> Generator {
        return Generator(_base: _MutualIterator(self))
    }

}

#endif

extension Bitboard: IntegerLiteralConvertible {
    /// Create an instance initialized to `value`.
    public init(integerLiteral value: UInt64) {
        rawValue = value
    }
}

/// Returns the intersection of bits set in `lhs` and `rhs`.
///
/// - complexity: O(1).
@warn_unused_result
public func & (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue & rhs.rawValue)
}

/// Returns the union of bits set in `lhs` and `rhs`.
///
/// - complexity: O(1).
@warn_unused_result
public func | (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue | rhs.rawValue)
}

/// Returns the bits that are set in exactly one of `lhs` and `rhs`.
///
/// - complexity: O(1).
@warn_unused_result
public func ^ (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue ^ rhs.rawValue)
}

/// Returns `x ^ ~Self.allZeros`.
///
/// - complexity: O(1).
@warn_unused_result
public prefix func ~ (x: Bitboard) -> Bitboard {
    return Bitboard(rawValue: ~x.rawValue)
}

/// Returns the bits of `lhs` shifted right by `rhs`.
@warn_unused_result
public func >> (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue >> rhs.rawValue)
}

/// Returns the bits of `lhs` shifted left by `rhs`.
@warn_unused_result
public func << (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
    return Bitboard(rawValue: lhs.rawValue << rhs.rawValue)
}

#if swift(>=3)

/// Shifts the bits of `lhs` right by `rhs`.
public func >>= (lhs: inout Bitboard, rhs: Bitboard) {
    lhs.rawValue >>= rhs.rawValue
}

/// Shifts the bits of `lhs` left by `rhs`.
public func <<= (lhs: inout Bitboard, rhs: Bitboard) {
    lhs.rawValue <<= rhs.rawValue
}

#else

/// Shifts the bits of `lhs` right by `rhs`.
public func >>= (inout lhs: Bitboard, rhs: Bitboard) {
    lhs.rawValue >>= rhs.rawValue
}

/// Shifts the bits of `lhs` left by `rhs`.
public func <<= (inout lhs: Bitboard, rhs: Bitboard) {
    lhs.rawValue <<= rhs.rawValue
}

#endif
