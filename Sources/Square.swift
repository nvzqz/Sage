//
//  Square.swift
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

/// A pair of a chess board `File` and `Rank`.
public typealias Location = (file: File, rank: Rank)

/// A chess board square.
///
/// A `Square` can be one of sixty-four possible values, ranging from `A1` to `H8`.
public enum Square: Int, CustomStringConvertible {

    #if swift(>=3)

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

    #else

    /// A1 square.
    case A1

    /// B1 square.
    case B1

    /// C1 square.
    case C1

    /// D1 square.
    case D1

    /// E1 square.
    case E1

    /// F1 square.
    case F1

    /// G1 square.
    case G1

    /// H1 square.
    case H1

    /// A2 square.
    case A2

    /// B2 square.
    case B2

    /// C2 square.
    case C2

    /// D2 square.
    case D2

    /// E2 square.
    case E2

    /// F2 square.
    case F2

    /// G2 square.
    case G2

    /// H2 square.
    case H2

    /// A3 square.
    case A3

    /// B3 square.
    case B3

    /// C3 square.
    case C3

    /// D3 square.
    case D3

    /// E3 square.
    case E3

    /// F3 square.
    case F3

    /// G3 square.
    case G3

    /// H3 square.
    case H3

    /// A4 square.
    case A4

    /// B4 square.
    case B4

    /// C4 square.
    case C4

    /// D4 square.
    case D4

    /// E4 square.
    case E4

    /// F4 square.
    case F4

    /// G4 square.
    case G4

    /// H4 square.
    case H4

    /// A5 square.
    case A5

    /// B5 square.
    case B5

    /// C5 square.
    case C5

    /// D5 square.
    case D5

    /// E5 square.
    case E5

    /// F5 square.
    case F5

    /// G5 square.
    case G5

    /// H5 square.
    case H5

    /// A6 square.
    case A6

    /// B6 square.
    case B6

    /// C6 square.
    case C6

    /// D6 square.
    case D6

    /// E6 square.
    case E6

    /// F6 square.
    case F6

    /// G6 square.
    case G6

    /// H6 square.
    case H6

    /// A7 square.
    case A7

    /// B7 square.
    case B7

    /// C7 square.
    case C7

    /// D7 square.
    case D7

    /// E7 square.
    case E7

    /// F7 square.
    case F7

    /// G7 square.
    case G7

    /// H7 square.
    case H7

    /// A8 square.
    case A8

    /// B8 square.
    case B8

    /// C8 square.
    case C8

    /// D8 square.
    case D8

    /// E8 square.
    case E8

    /// F8 square.
    case F8

    /// G8 square.
    case G8

    /// H8 square.
    case H8

    #endif

}

extension Square {

    /// An array of all squares.
    public static let all: [Square] = (0 ..< 64).flatMap(Square.init(rawValue:))

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
        return (file.index & 1 != rank.index & 1) ? ._white : ._black
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
        guard let file = file, rank = rank else {
            return nil
        }
        self.init(file: file, rank: rank)
    }

    /// Create a square from `string`.
    public init?(_ string: String) {
        let chars = string.characters
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
    @warn_unused_result
    public func attacks(for piece: Piece, stoppers: Bitboard = 0) -> Bitboard {
        #if swift(>=3)
            switch piece {
            case .king:
                return kingAttacks()
            case .knight:
                return knightAttacks()
            case .pawn(let color):
                return _pawnAttackTable(for: color)[rawValue]
            default:
                return Bitboard(square: self)._attacks(for: piece, stoppers: stoppers)
            }
        #else
            switch piece {
            case .King:
                return kingAttacks()
            case .Knight:
                return knightAttacks()
            case .Pawn(let color):
                return _pawnAttackTable(for: color)[rawValue]
            default:
                return Bitboard(square: self)._attacks(for: piece, stoppers: stoppers)
            }
        #endif
    }

    /// Returns an array of attack moves for a piece at `self`.
    ///
    /// - seealso: `attacks(for:stoppers:)`
    @warn_unused_result
    public func attackMoves(for piece: Piece, stoppers: Bitboard = 0) -> [Move] {
        return attacks(for: piece, stoppers: stoppers).moves(from: self)
    }

    #if swift(>=3)

    /// Returns moves from the squares in `squares` to `self`.
    @warn_unused_result
    public func moves<S: Sequence where S.Iterator.Element == Square>(from squares: S) -> [Move] {
        return squares.moves(to: self)
    }

    /// Returns moves from `self` to the squares in `squares`.
    @warn_unused_result
    public func moves<S: Sequence where S.Iterator.Element == Square>(to squares: S) -> [Move] {
        return squares.moves(from: self)
    }

    #else

    /// Returns moves from the squares in `squares` to `self`.
    @warn_unused_result
    public func moves<S: SequenceType where S.Generator.Element == Square>(from squares: S) -> [Move] {
        return squares.moves(to: self)
    }

    /// Returns moves from `self` to the squares in `squares`.
    @warn_unused_result
    public func moves<S: SequenceType where S.Generator.Element == Square>(to squares: S) -> [Move] {
        return squares.moves(from: self)
    }

    #endif

}

extension Square: StringLiteralConvertible {

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
