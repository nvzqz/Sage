//
//  Square.swift
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

/// A chess location.
public typealias Location = (file: File, rank: Rank)

/// A board location square.
public enum Square: Int, CustomStringConvertible {

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

    /// An array of all squares.
    public static let all: [Square] = (0 ..< 64).flatMap(Square.init(rawValue:))

    /// The file of `self`.
    public var file: File {
        get {
            return File(column: rawValue % 8)!
        }
        set(newFile) {
            self = Square(file: newFile, rank: rank)
        }
    }

    /// The rank of `self`.
    public var rank: Rank {
        get {
            return Rank(row: rawValue / 8)!
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

    /// A textual representation of `self`.
    public var description: String {
        return "\(file)\(rank)"
    }

    /// Create a square from `file` and `rank`.
    public init(file: File, rank: Rank) {
        self.init(rawValue: file.index + (8 * rank.index))!
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
    @warn_unused_result
    public func kingAttacks() -> Bitboard {
        return _kingAttackTable[rawValue]
    }

    /// Returns a bitboard mask of attacks for a knight at `self`.
    @warn_unused_result
    public func knightAttacks() -> Bitboard {
        return _knightAttackTable[rawValue]
    }

    /// Returns a bitboard mask of attacks for a piece at `self`.
    ///
    /// - Parameter piece: The piece for the attacks.
    /// - Parameter stoppers: The pieces stopping a sliding move. The returned
    ///   bitboard includes the stopped space.
    ///
    /// - SeeAlso: `attackMoves(for:stoppers:)`
    @warn_unused_result
    public func attacks(for piece: Piece, stoppers: Bitboard = 0) -> Bitboard {
        switch piece {
        case .King:
            return kingAttacks()
        case .Knight:
            return knightAttacks()
        case .Pawn(let color):
            return _pawnAttackTable(for: color)[rawValue]
        default:
            let bb = Bitboard(square: self)
            return bb._attacks(for: piece, stoppers: stoppers)
        }
    }

    /// Returns an array of attack moves for a piece at `self`.
    ///
    /// - SeeAlso: `attacks(for:stoppers:)`
    @warn_unused_result
    public func attackMoves(for piece: Piece, stoppers: Bitboard = 0) -> [Move] {
        return attacks(for: piece, stoppers: stoppers).moves(from: self)
    }

}
