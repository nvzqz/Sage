//
//  Piece.swift
//  Fischer
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

/// A chess piece.
public enum Piece: Hashable, CustomStringConvertible {

    /// Pawn piece.
    case Pawn(Color)

    /// Knight piece.
    case Knight(Color)

    /// Bishop piece.
    case Bishop(Color)

    /// Rook piece.
    case Rook(Color)

    /// Queen piece.
    case Queen(Color)

    /// King piece.
    case King(Color)

    /// An array of all pieces.
    public static let all: [Piece] = [.Pawn(.White),   .Knight(.White),
                                      .Bishop(.White), .Rook(.White),
                                      .Queen(.White),  .King(.White),
                                      .Pawn(.Black),   .Knight(.Black),
                                      .Bishop(.Black), .Rook(.Black),
                                      .Queen(.Black),  .King(.Black)]

    /// An array of all white pieces.
    public static let whitePieces: [Piece] = all.filter({ $0.color == .White })

    /// An array of all black pieces.
    public static let blackPieces: [Piece] = all.filter({ $0.color == .Black })

    /// Returns an array of all pieces for `color`.
    public static func pieces(for color: Color) -> [Piece] {
        return color.isWhite ? whitePieces : blackPieces
    }

    /// The piece's color.
    public var color: Color {
        get {
            switch self {
            case let .Pawn(color):   return color
            case let .Rook(color):   return color
            case let .Knight(color): return color
            case let .Bishop(color): return color
            case let .King(color):   return color
            case let .Queen(color):  return color
            }
        }
        set(newColor) {
            switch self {
            case .Pawn:   self = .Pawn(newColor)
            case .Rook:   self = .Rook(newColor)
            case .Knight: self = .Knight(newColor)
            case .Bishop: self = .Bishop(newColor)
            case .King:   self = .King(newColor)
            case .Queen:  self = .Queen(newColor)
            }
        }
    }

    /// The piece's name.
    public var name: String {
        switch self {
        case .Pawn:   return "Pawn"
        case .Knight: return "Knight"
        case .Bishop: return "Bishop"
        case .Rook:   return "Rook"
        case .Queen:  return "Queen"
        case .King:   return "King"
        }
    }

    /// The character for the piece. Uppercase if white or lowercase if black.
    public var character: Character {
        switch self {
        case let .Pawn(color):   return color.isWhite ? "P" : "p"
        case let .Knight(color): return color.isWhite ? "N" : "n"
        case let .Bishop(color): return color.isWhite ? "B" : "b"
        case let .Rook(color):   return color.isWhite ? "R" : "r"
        case let .Queen(color):  return color.isWhite ? "Q" : "q"
        case let .King(color):   return color.isWhite ? "K" : "k"
        }
    }

    /// The piece's relative value. Can be used to determine how valuable a piece or combination of pieces is.
    public var relativeValue: Double {
        switch self {
        case .Pawn:   return 1
        case .Knight: return 3
        case .Bishop: return 3.25
        case .Rook:   return 5
        case .Queen:  return 9
        case .King:   return .infinity
        }
    }

    /// The piece can be promoted. Only pawns are promotable.
    public var isPromotable: Bool {
        return isPawn
    }

    /// The piece is `Pawn`.
    public var isPawn: Bool {
        if case .Pawn = self { return true } else { return false }
    }

    /// The piece `Knight`.
    public var isKnight: Bool {
        if case .Knight = self { return true } else { return false }
    }

    /// The piece is `Bishop`.
    public var isBishop: Bool {
        if case .Bishop = self { return true } else { return false }
    }

    /// The piece is `Rook`.
    public var isRook: Bool {
        if case .Rook = self { return true } else { return false }
    }

    /// The piece is `Queen`.
    public var isQueen: Bool {
        if case .Queen = self { return true } else { return false }
    }

    /// The piece is `King`.
    public var isKing: Bool {
        if case .King = self { return true } else { return false }
    }

    /// A textual representation of `self`.
    public var description: String {
        return "\(name)(\(color))"
    }

    /// The hash value.
    public var hashValue: Int {
        switch self {
        case let .Pawn(color):   return (0 << 1) | color.hashValue
        case let .Knight(color): return (1 << 1) | color.hashValue
        case let .Bishop(color): return (2 << 1) | color.hashValue
        case let .Rook(color):   return (3 << 1) | color.hashValue
        case let .Queen(color):  return (4 << 1) | color.hashValue
        case let .King(color):   return (5 << 1) | color.hashValue
        }
    }

    /// Create a piece from a character.
    public init?(character: Character) {
        switch character {
        case "P": self = .Pawn(.White)
        case "p": self = .Pawn(.Black)
        case "N": self = .Knight(.White)
        case "n": self = .Knight(.Black)
        case "B": self = .Bishop(.White)
        case "b": self = .Bishop(.Black)
        case "R": self = .Rook(.White)
        case "r": self = .Rook(.Black)
        case "Q": self = .Queen(.White)
        case "q": self = .Queen(.Black)
        case "K": self = .King(.White)
        case "k": self = .King(.Black)
        default:
            return nil
        }
    }

    /// Returns `true` if `self` can be a promotion for the piece.
    public func canPromote(piece: Piece) -> Bool {
        if case let .Pawn(color) = piece {
            return canPromote(color)
        } else {
            return false
        }
    }

    /// Returns `true` if `self` can be a promotion for the color.
    public func canPromote(color: Color? = nil) -> Bool {
        switch self {
        case .Pawn, .King:
            return false
        default:
            if let color = color {
                return self.color == color
            } else {
                return true
            }
        }
    }

    /// The special character for the piece.
    public func specialCharacter(background color: Color = .White) -> Character {
        switch self {
        case let .Pawn(c):   return color == c ? "♙" : "♟"
        case let .Knight(c): return color == c ? "♘" : "♞"
        case let .Bishop(c): return color == c ? "♗" : "♝"
        case let .Rook(c):   return color == c ? "♖" : "♜"
        case let .Queen(c):  return color == c ? "♕" : "♛"
        case let .King(c):   return color == c ? "♔" : "♚"
        }
    }

}

/// Returns `true` if both pieces are the same.
@warn_unused_result
public func == (lhs: Piece, rhs: Piece) -> Bool {
    switch (lhs, rhs) {
    case let (.Pawn(cl), .Pawn(cr)):
        return cl == cr
    case let (.Knight(cl), .Knight(cr)):
        return cl == cr
    case let (.Bishop(cl), .Bishop(cr)):
        return cl == cr
    case let (.Rook(cl), .Rook(cr)):
        return cl == cr
    case let (.Queen(cl), .Queen(cr)):
        return cl == cr
    case let (.King(cl), .King(cr)):
        return cl == cr
    default:
        return false
    }
}
