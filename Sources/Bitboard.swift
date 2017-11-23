//
//  Bitboard.swift
//  Sage
//
//  Copyright 2016-2017 Nikolai Vazquez
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
private let _lsbTable: [Int] = [00, 01, 48, 02, 57, 49, 28, 03,
                                61, 58, 50, 42, 38, 29, 17, 04,
                                62, 55, 59, 36, 53, 51, 43, 22,
                                45, 39, 33, 30, 24, 18, 12, 05,
                                63, 47, 56, 27, 60, 41, 37, 16,
                                54, 35, 52, 21, 44, 32, 23, 11,
                                46, 26, 40, 15, 34, 20, 31, 10,
                                25, 14, 19, 09, 13, 08, 07, 06]

/// A lookup table of most significant bit indices.
private let _msbTable: [Int] = [00, 47, 01, 56, 48, 27, 02, 60,
                                57, 49, 41, 37, 28, 16, 03, 61,
                                54, 58, 35, 52, 50, 42, 21, 44,
                                38, 32, 29, 23, 17, 11, 04, 62,
                                46, 55, 26, 59, 40, 36, 15, 53,
                                34, 51, 20, 43, 31, 22, 10, 45,
                                25, 39, 14, 33, 19, 30, 09, 24,
                                13, 18, 08, 12, 07, 06, 05, 63]

/// A lookup table of bitboards for all squares.
private let _bitboardTable: [Bitboard] = (0..<64).map {
    Bitboard(rawValue: 1 << $0)
}

/// The De Bruijn multiplier.
private let _debruijn64: UInt64 = 0x03f79d71b4cb0a89

/// Returns the index of the lsb value.
private func _index(lsb value: Bitboard) -> Int? {
    guard value != 0 else {
        return nil
    }
    return _lsbTable[Int((value.rawValue &* _debruijn64) >> 58)]
}

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

    }

    /// An iterator for the squares of a `Bitboard`.
    public struct Iterator: IteratorProtocol {

        fileprivate var _bitboard: Bitboard

        /// Advances and returns the next element of the underlying sequence, or
        /// `nil` if no next element exists.
        public mutating func next() -> Square? {
            return _bitboard.popLSBSquare()
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
    /// `Bitboard(rawValue: self.rawValue)!` is equivalent to `self`.
    public var rawValue: UInt64

    /// A textual representation of `self`.
    public var description: String {
        let num = String(rawValue, radix: 16)
        let str = repeatElement("0", count: 16 - num.count).joined(separator: "")
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
        let ranks = Rank.all.reversed()
        for rank in ranks {
            let strings = File.all.map({ file in self[(file, rank)] ? "1" : "." })
            let str = strings.joined(separator: " ")
            result += "\(rank) | \(str) |\n"
        }
        result += "\(edge)    a b c d e f g h  "
        return result
    }

    /// The number of bits set in `self`.
    public var count: Int {
        var n = rawValue
        n -= ((n >> 1) & 0x5555555555555555)
        n = (n & 0x3333333333333333) + ((n >> 2) & 0x3333333333333333)
        return Int((((n + (n >> 4)) & 0xF0F0F0F0F0F0F0F) &* 0x101010101010101) >> 56)
    }

    /// `true` if `self` is empty.
    public var isEmpty: Bool {
        return self == 0
    }

    /// `self` has more than one bit set.
    public var hasMoreThanOne: Bool {
        return rawValue & (rawValue &- 1) != 0
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

    private var _msbShifted: UInt64 {
        var x = rawValue
        x |= x >> 1
        x |= x >> 2
        x |= x >> 4
        x |= x >> 8
        x |= x >> 16
        x |= x >> 32
        return x
    }

    /// The most significant bit.
    public var msb: Bitboard {
        return Bitboard(rawValue: (_msbShifted >> 1) + 1)
    }

    /// The index for the most significant bit of `self`.
    public var msbIndex: Int? {
        guard rawValue != 0 else {
            return nil
        }
        return _msbTable[Int((_msbShifted &* _debruijn64) >> 58)]
    }

    /// The square for the most significant bit of `self`.
    public var msbSquare: Square? {
        return msbIndex.flatMap({ Square(rawValue: $0) })
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
        let value: Bitboard
        switch piece.kind {
        case .pawn:   value = 0xFF00
        case .knight: value = 0x0042
        case .bishop: value = 0x0024
        case .rook:   value = 0x0081
        case .queen:  value = 0x0008
        case .king:   value = 0x0010
        }
        self = piece.color.isWhite ? value : value << (piece.kind.isPawn ? 40 : 56)
    }

    /// Create a bitboard from `squares`.
    public init<S: Sequence>(squares: S) where S.Iterator.Element == Square {
        rawValue = squares.reduce(0) {
            $0 | (1 << UInt64($1.rawValue))
        }
    }

    /// Create a bitboard from `locations`.
    public init<S: Sequence>(locations: S) where S.Iterator.Element == Location {
        self.init(squares: locations.map(Square.init(location:)))
    }

    /// Create a bitboard from the start and end of `move`.
    public init(move: Move) {
        self.init(squares: [move.start, move.end])
    }

    /// Create a bitboard mask for `file`.
    public init(file: File) {
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
    internal func _pawnPushes(for color: Color, empty: Bitboard) -> Bitboard {
        return (color.isWhite ? shifted(toward: .north) : shifted(toward: .south)) & empty
    }

    /// Returns the attacks available to the pawns for `color` in `self`.
    internal func _pawnAttacks(for color: Color) -> Bitboard {
        if color.isWhite {
            return shifted(toward: .northeast) | shifted(toward: .northwest)
        } else {
            return shifted(toward: .southeast) | shifted(toward: .southwest)
        }
    }

    /// Returns the attacks available to the knight in `self`.
    internal func _knightAttacks() -> Bitboard {
        let x = self
        let a = ((x << 17) | (x >> 15)) & _notFileA
        let b = ((x << 10) | (x >> 06)) & _notFileAB
        let c = ((x << 15) | (x >> 17)) & _notFileH
        let d = ((x << 06) | (x >> 10)) & _notFileGH
        return a | b | c | d
    }

    /// Returns the attacks available to the bishop in `self`.
    internal func _bishopAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return filled(toward: .northeast, stoppers: bitboard).shifted(toward: .northeast)
                | filled(toward: .northwest, stoppers: bitboard).shifted(toward: .northwest)
                | filled(toward: .southeast, stoppers: bitboard).shifted(toward: .southeast)
                | filled(toward: .southwest, stoppers: bitboard).shifted(toward: .southwest)
    }

    /// Returns the attacks available to the rook in `self`.
    internal func _rookAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return filled(toward: .north, stoppers: bitboard).shifted(toward: .north)
                | filled(toward: .south, stoppers: bitboard).shifted(toward: .south)
                | filled(toward: .east, stoppers: bitboard).shifted(toward: .east)
                | filled(toward: .west, stoppers: bitboard).shifted(toward: .west)
    }

    /// Returns the x-ray attacks available to the bishop in `self`.
    internal func _xrayBishopAttacks(occupied occ: Bitboard, stoppers: Bitboard) -> Bitboard {
        let attacks = _bishopAttacks(stoppers: occ)
        return attacks ^ _bishopAttacks(stoppers: (stoppers & attacks) ^ stoppers)
    }

    /// Returns the x-ray attacks available to the rook in `self`.
    internal func _xrayRookAttacks(occupied occ: Bitboard, stoppers: Bitboard) -> Bitboard {
        let attacks = _rookAttacks(stoppers: occ)
        return attacks ^ _rookAttacks(stoppers: (stoppers & attacks) ^ stoppers)
    }

    /// Returns the attacks available to the queen in `self`.
    internal func _queenAttacks(stoppers bitboard: Bitboard = 0) -> Bitboard {
        return _rookAttacks(stoppers: bitboard) | _bishopAttacks(stoppers: bitboard)
    }

    /// Returns the attacks available to the king in `self`.
    internal func _kingAttacks() -> Bitboard {
        let attacks = shifted(toward: .east) | shifted(toward: .west)
        let bitboard = self | attacks
        return attacks
                | bitboard.shifted(toward: .north)
                | bitboard.shifted(toward: .south)
    }

    /// Returns the attacks available to `piece` in `self`.
    internal func _attacks(for piece: Piece, stoppers: Bitboard = 0) -> Bitboard {

        switch piece.kind {
        case .pawn:
            return _pawnAttacks(for: piece.color)
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

    }

    /// Returns `true` if `self` intersects `other`.
    public func intersects(_ other: Bitboard) -> Bool {
        return rawValue & other.rawValue != 0
    }

    /// Returns `self` flipped horizontally.
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

    /// Returns `self` flipped vertically.
    public func flippedVertically() -> Bitboard {
        let x = 0x00FF00FF00FF00FF as Bitboard
        let y = 0x0000FFFF0000FFFF as Bitboard
        var n = self
        n = ((n >> 8) & x) | ((n & x) << 8)
        n = ((n >> 16) & y) | ((n & y) << 16)
        n = (n >> 32) | (n << 32)
        return n
    }

    /// Returns the bits of `self` filled toward `direction` stopped by `stoppers`.
    public func filled(toward direction: ShiftDirection, stoppers: Bitboard) -> Bitboard {
        let empty = ~stoppers
        var bitboard = self
        for _ in 0..<7 {
            bitboard |= empty & bitboard.shifted(toward: direction)
        }
        return bitboard
    }

    /// Returns the bits of `self` shifted once toward `direction`.
    public func shifted(toward direction: ShiftDirection) -> Bitboard {
        switch direction {
        case .north:     return self << 8
        case .south:     return self >> 8
        case .east:      return (self << 1) & _notFileA
        case .northeast: return (self << 9) & _notFileA
        case .southeast: return (self >> 7) & _notFileA
        case .west:      return (self >> 1) & _notFileH
        case .southwest: return (self >> 9) & _notFileH
        case .northwest: return (self << 7) & _notFileH
        }
    }

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

    /// Removes the most significant bit and returns it.
    public mutating func popMSB() -> Bitboard {
        let msb = self.msb
        rawValue -= msb.rawValue
        return msb
    }

    /// Removes the most significant bit and returns its index, if any.
    public mutating func popMSBIndex() -> Int? {
        guard rawValue != 0 else {
            return nil
        }
        let shifted = _msbShifted
        rawValue -= (shifted >> 1) + 1
        return _msbTable[Int((shifted &* _debruijn64) >> 58)]
    }

    /// Removes the most significant bit and returns its square, if any.
    public mutating func popMSBSquare() -> Square? {
        return popMSBIndex().flatMap({ Square(rawValue: $0) })
    }

    /// Returns the ranks of `self` as eight 8-bit integers.
    public func ranks() -> [UInt8] {
        return (0..<8).map {
            UInt8((rawValue >> ($0 * 8)) & 255)
        }
    }

    public static func == (lhs: Bitboard, rhs: Bitboard) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

}

extension Bitboard: Sequence {

    /// A value less than or equal to the number of elements in
    /// the sequence, calculated nondestructively.
    ///
    /// - complexity: O(1).
    public var underestimatedCount: Int {
        return count
    }

    /// Returns a Boolean value indicating whether the sequence contains the
    /// given element.
    ///
    /// - complexity: O(1).
    public func contains(_ element: Square) -> Bool {
        return self[element]
    }

    /// Returns an iterator over the squares of the board.
    public func makeIterator() -> Iterator {
        return Iterator(_bitboard: self)
    }

}

extension Bitboard: ExpressibleByIntegerLiteral {
    /// Create an instance initialized to `value`.
    public init(integerLiteral value: UInt64) {
        rawValue = value
    }
}

extension Bitboard: Numeric {

    public var magnitude: Bitboard.Magnitude {
        return rawValue.magnitude
    }

    public static func + (_ lhs: Bitboard, _ rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue + rhs.rawValue)
    }

    public static func += (_ lhs: inout Bitboard, _ rhs: Bitboard) {
        // swiftlint:disable shorthand_operator
        lhs = lhs + rhs
        // swiftlint:enable shorthand_operator
    }

    public static func - (_ lhs: Bitboard, _ rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue - rhs.rawValue)
    }

    public static func -= (_ lhs: inout Bitboard, _ rhs: Bitboard) {
        // swiftlint:disable shorthand_operator
        lhs = lhs - rhs
        // swiftlint:enable shorthand_operator
    }

    public static func * (_ lhs: Bitboard, _ rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue * rhs.rawValue)
    }

    public static func *= (_ lhs: inout Bitboard, _ rhs: Bitboard) {
        // swiftlint:disable shorthand_operator
        lhs = lhs * rhs
        // swiftlint:enable shorthand_operator
    }

    public init?<T>(exactly source: T) where T: BinaryInteger {
        guard let rawValue = UInt64(exactly: source) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}

extension Bitboard: BinaryInteger {

    public typealias Magnitude = UInt64.Magnitude

    public static private(set) var isSigned = UInt64.isSigned
    public static private(set) var bitWidth = UInt64.bitWidth

    // MARK: Instance Methods
    public var words: UInt64.Words {
        return rawValue.words
    }

    public var trailingZeroBitCount: Int {
        return rawValue.trailingZeroBitCount
    }

    // MARK: Initializers

    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard let rawValue = UInt64(exactly: source) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }

    public init<T>(_ source: T) where T: BinaryFloatingPoint {
        self.init(rawValue: UInt64(source))
    }

    public init<T>(_ source: T) where T: BinaryInteger {
        self.init(rawValue: UInt64(source))
    }

    // MARK: Type Methods

    public static func / (_ lhs: Bitboard, _ rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue / rhs.rawValue)
    }

    public static func /= (_ lhs: inout Bitboard, _ rhs: Bitboard) {
        // swiftlint:disable shorthand_operator
        lhs = lhs / rhs
        // swiftlint:enable shorthand_operator
    }

    public static func % (_ lhs: Bitboard, _ rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue % rhs.rawValue)
    }

    public static func %= (_ lhs: inout Bitboard, _ rhs: Bitboard) {
        lhs = lhs % rhs
    }

    prefix public static func ~ (x: Bitboard) -> Bitboard {
        return Bitboard(rawValue: ~x.rawValue)
    }

    public static func & (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue & rhs.rawValue)
    }

    public static func &= (lhs: inout Bitboard, rhs: Bitboard) {
        lhs = lhs & rhs
    }

    public static func | (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue | rhs.rawValue)
    }

    public static func |= (lhs: inout Bitboard, rhs: Bitboard) {
        lhs = lhs | rhs
    }

    public static func ^ (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue ^ rhs.rawValue)
    }

    public static func ^= (lhs: inout Bitboard, rhs: Bitboard) {
        lhs = lhs ^ rhs
    }

    public static func >> <RHS>(lhs: Bitboard, rhs: RHS) -> Bitboard where RHS: BinaryInteger {
        return Bitboard(rawValue: lhs.rawValue >> rhs)
    }

    public static func >>= <RHS>(lhs: inout Bitboard, rhs: RHS) where RHS: BinaryInteger {
        lhs = lhs >> rhs
    }

    public static func << <RHS>(lhs: Bitboard, rhs: RHS) -> Bitboard where RHS: BinaryInteger {
        return Bitboard(rawValue: lhs.rawValue << rhs)
    }

    public static func <<= <RHS>(lhs: inout Bitboard, rhs: RHS) where RHS: BinaryInteger {
        lhs = lhs << rhs
    }
}

extension Bitboard: FixedWidthInteger {

    public private(set) static var min = Bitboard(rawValue: UInt64.min)
    public private(set) static var max = Bitboard(rawValue: UInt64.max)

    // MARK: Instance Properties

    public var nonzeroBitCount: Int {
        return rawValue.nonzeroBitCount
    }

    public var leadingZeroBitCount: Int {
        return rawValue.leadingZeroBitCount
    }

    public var byteSwapped: Bitboard {
        return Bitboard(rawValue: rawValue.byteSwapped)
    }

    // MARK: Initializers

    public init(_truncatingBits bits: UInt) {
        self.init(rawValue: UInt64(_truncatingBits: bits))
    }

    // MARK: Instance Methods

    public func multipliedFullWidth(by other: Bitboard) -> (high: Bitboard, low: Bitboard.Magnitude) {
        let result = rawValue.multipliedFullWidth(by: other.rawValue)
        return (Bitboard(rawValue: result.high), low: result.low)
    }

    public func dividingFullWidth(_ dividend: (high: Bitboard, low: Bitboard.Magnitude)) ->
        (quotient: Bitboard, remainder: Bitboard) {
        let result = rawValue.dividingFullWidth((dividend.high.rawValue, dividend.low))
        return (Bitboard(rawValue: result.quotient), Bitboard(rawValue: result.remainder))
    }

    public func quotientAndRemainder(dividingBy rhs: Bitboard) -> (quotient: Bitboard, remainder: Bitboard) {
        let result = rawValue.quotientAndRemainder(dividingBy: rhs.rawValue)
        return (Bitboard(rawValue: result.quotient), Bitboard(rawValue: result.remainder))
    }

    public func addingReportingOverflow(_ rhs: Bitboard) -> (partialValue: Bitboard, overflow: Bool) {
        let result = self.rawValue.addingReportingOverflow(rhs.rawValue)
        return (Bitboard(rawValue: result.partialValue), result.overflow)
    }

    public func subtractingReportingOverflow(_ rhs: Bitboard) -> (partialValue: Bitboard, overflow: Bool) {
        let result = self.rawValue.subtractingReportingOverflow(rhs.rawValue)
        return (Bitboard(rawValue: result.partialValue), result.overflow)
    }

    public func multipliedReportingOverflow(by rhs: Bitboard) -> (partialValue: Bitboard, overflow: Bool) {
        let result = self.rawValue.multipliedReportingOverflow(by: rhs.rawValue)
        return (Bitboard(rawValue: result.partialValue), result.overflow)
    }

    public func dividedReportingOverflow(by rhs: Bitboard) -> (partialValue: Bitboard, overflow: Bool) {
        let result = self.rawValue.dividedReportingOverflow(by: rhs.rawValue)
        return (Bitboard(rawValue: result.partialValue), result.overflow)
    }

    public func remainderReportingOverflow(dividingBy rhs: Bitboard) -> (partialValue: Bitboard, overflow: Bool) {
        let result = self.rawValue.remainderReportingOverflow(dividingBy: rhs.rawValue)
        return (Bitboard(rawValue: result.partialValue), result.overflow)
    }

    public static func &>>= (_ lhs: inout Bitboard, _ rhs: Bitboard) {
        lhs = lhs &>> rhs
    }

    public static func &<<= (_ lhs: inout Bitboard, _ rhs: Bitboard) {
        lhs = lhs &<< rhs
    }

    public static func &>> (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue &>> rhs.rawValue)
    }

    public static func &<< (lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        return Bitboard(rawValue: lhs.rawValue &<< rhs.rawValue)
    }
}
