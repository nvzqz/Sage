//
//  Square.swift
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

/// A pair of a chess board `File` and `Rank`.
public typealias Location = (file: File, rank: Rank)

/// A chess board square.
///
/// A `Square` can be one of sixty-four possible values, ranging from `A1` to `H8`.
public enum Square: Int, CustomStringConvertible {

    /// A1 square.
    case a1

    /// B1 square.
    case b1

    /// C1 square.
    case c1

    /// D1 square.
    case d1

    /// E1 square.
    case e1

    /// F1 square.
    case f1

    /// G1 square.
    case g1

    /// H1 square.
    case h1

    /// A2 square.
    case a2

    /// B2 square.
    case b2

    /// C2 square.
    case c2

    /// D2 square.
    case d2

    /// E2 square.
    case e2

    /// F2 square.
    case f2

    /// G2 square.
    case g2

    /// H2 square.
    case h2

    /// A3 square.
    case a3

    /// B3 square.
    case b3

    /// C3 square.
    case c3

    /// D3 square.
    case d3

    /// E3 square.
    case e3

    /// F3 square.
    case f3

    /// G3 square.
    case g3

    /// H3 square.
    case h3

    /// A4 square.
    case a4

    /// B4 square.
    case b4

    /// C4 square.
    case c4

    /// D4 square.
    case d4

    /// E4 square.
    case e4

    /// F4 square.
    case f4

    /// G4 square.
    case g4

    /// H4 square.
    case h4

    /// A5 square.
    case a5

    /// B5 square.
    case b5

    /// C5 square.
    case c5

    /// D5 square.
    case d5

    /// E5 square.
    case e5

    /// F5 square.
    case f5

    /// G5 square.
    case g5

    /// H5 square.
    case h5

    /// A6 square.
    case a6

    /// B6 square.
    case b6

    /// C6 square.
    case c6

    /// D6 square.
    case d6

    /// E6 square.
    case e6

    /// F6 square.
    case f6

    /// G6 square.
    case g6

    /// H6 square.
    case h6

    /// A7 square.
    case a7

    /// B7 square.
    case b7

    /// C7 square.
    case c7

    /// D7 square.
    case d7

    /// E7 square.
    case e7

    /// F7 square.
    case f7

    /// G7 square.
    case g7

    /// H7 square.
    case h7

    /// A8 square.
    case a8

    /// B8 square.
    case b8

    /// C8 square.
    case c8

    /// D8 square.
    case d8

    /// E8 square.
    case e8

    /// F8 square.
    case f8

    /// G8 square.
    case g8

    /// H8 square.
    case h8

}

extension Square {

    /// An array of all squares.
    public static let all: [Square] = (0..<64).flatMap(Square.init(rawValue:))

    /// The file of `self`.
    public var file: File {
        get {
            return File(index: rawValue & 7)!
        }
        set(newFile) {
            self = Square(file: newFile, rank: rank)
        }
    }

    /// The rank of `self`.
    public var rank: Rank {
        get {
            return Rank(index: rawValue >> 3)!
        }
        set(newRank) {
            self = Square(file: file, rank: newRank)
        }
    }

    /// The location of `self`.
    public var location: Location {
        get {
            return (file, rank)
        }
        set(newLocation) {
            self = Square(location: newLocation)
        }
    }

    /// The square's color.
    public var color: Color {
        return (file.index & 1 != rank.index & 1) ? .white : .black
    }

    /// A textual representation of `self`.
    public var description: String {
        return "\(file)\(rank)"
    }

    /// Create a square from `file` and `rank`.
    public init(file: File, rank: Rank) {
        self.init(rawValue: file.index + (rank.index << 3))!
    }

    /// Create a square from `location`.
    public init(location: Location) {
        self.init(file: location.file, rank: location.rank)
    }

    /// Create a square from `file` and `rank`. Returns `nil` if either is `nil`.
    public init?(file: File?, rank: Rank?) {
        guard let file = file, let rank = rank else {
            return nil
        }
        self.init(file: file, rank: rank)
    }

    /// Create a square from `string`.
    public init?(_ string: String) {
        let chars = string
        guard chars.count == 2 else {
            return nil
        }
        guard let file = File(chars.first!) else {
            return nil
        }
        guard let rank = Int(String(chars.last!)).flatMap(Rank.init(_:)) else {
            return nil
        }
        self.init(file: file, rank: rank)
    }

    /// Returns the squares between `self` and `other`.
    public func between(_ other: Square) -> Bitboard {
        return _betweenTable[_triangleIndex(self, other)]
    }

    /// Returns the squares along the line with `other`.
    public func line(with other: Square) -> Bitboard {
        return _lineTable[_triangleIndex(self, other)]
    }

    /// Returns `true` if `self` is between `start` and `end`.
    public func isBetween(start: Square, end: Square) -> Bool {
        return start.between(end)[self]
    }

    /// Returns `true` if `self` is aligned with `first` and `second`.
    public func isAligned(with first: Square, and second: Square) -> Bool {
        return line(with: first)[second]
                || line(with: second)[first]
                || (self == first && self == second)
    }

    /// Returns `true` if `self` is aligned with `first` and `rest`.
    public func isAligned(with first: Square, _ rest: Square...) -> Bool {
        var line = self == first ? Bitboard(square: self) : self.line(with: first)
        for square in rest where square != self {
            if line == Bitboard(square: self) {
                line = self.line(with: square)
            }
            guard line[square] else {
                return false
            }
        }
        return !line.isEmpty
    }

    /// Returns `true` if `self` is aligned with `squares`.
    public func isAligned<S: Sequence>(with squares: S) -> Bool where S.Iterator.Element == Square {
        var line: Bitboard? = nil
        let bitboard = Bitboard(square: self)
        for square in squares {
            if let lineBitboard = line {
                if lineBitboard == bitboard {
                    line = self.line(with: square)
                } else {
                    guard lineBitboard[square] else {
                        return false
                    }
                }
            } else if square == self {
                line = bitboard
            } else {
                line = self.line(with: square)
            }
        }
        return line?.isEmpty == false
    }

    /// Returns a bitboard mask of attacks for a king at `self`.
    public func kingAttacks() -> Bitboard {
        return _kingAttackTable[rawValue]
    }

    /// Returns a bitboard mask of attacks for a knight at `self`.
    public func knightAttacks() -> Bitboard {
        return _knightAttackTable[rawValue]
    }

    /// Returns a bitboard mask of attacks for a piece at `self`.
    ///
    /// - parameter piece: The piece for the attacks.
    /// - parameter stoppers: The pieces stopping a sliding move. The returned bitboard includes the stopped space.
    ///
    /// - seealso: `attackMoves(for:stoppers:)`
    public func attacks(for piece: Piece, stoppers: Bitboard = 0) -> Bitboard {

        switch piece.kind {
        case .king:
            return kingAttacks()
        case .knight:
            return knightAttacks()
        case .pawn:
            return _pawnAttackTable(for: piece.color)[rawValue]
        default:
            return Bitboard(square: self)._attacks(for: piece, stoppers: stoppers)
        }

    }

    /// Returns an array of attack moves for a piece at `self`.
    ///
    /// - seealso: `attacks(for:stoppers:)`
    public func attackMoves(for piece: Piece, stoppers: Bitboard = 0) -> [Move] {
        return attacks(for: piece, stoppers: stoppers).moves(from: self)
    }

    /// Returns moves from the squares in `squares` to `self`.
    public func moves<S: Sequence>(from squares: S) -> [Move] where S.Iterator.Element == Square {
        return squares.moves(to: self)
    }

    /// Returns moves from `self` to the squares in `squares`.
    public func moves<S: Sequence>(to squares: S) -> [Move] where S.Iterator.Element == Square {
        return squares.moves(from: self)
    }

}

extension Square: ExpressibleByStringLiteral {
}

extension Square {

    /// Create an instance initialized to `value`.
    public init(stringLiteral value: String) {
        guard let square = Square(value) else {
            fatalError("Invalid string for square: \"\(value)\"")
        }
        self = square
    }

    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }

    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }

}
