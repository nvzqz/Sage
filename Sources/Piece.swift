//
//  Piece.swift
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

/// A chess piece.
public enum Piece: Hashable, CustomStringConvertible {

    #if swift(>=3)

    /// Pawn piece.
    case pawn(Color)

    /// Knight piece.
    case knight(Color)

    /// Bishop piece.
    case bishop(Color)

    /// Rook piece.
    case rook(Color)

    /// Queen piece.
    case queen(Color)

    /// King piece.
    case king(Color)

    #else

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

    #endif

}

extension Piece {

    #if swift(>=3)

    /// An array of all pieces.
    public static let all: [Piece] = [.pawn(.white),   .knight(.white),
                                      .bishop(.white), .rook(.white),
                                      .queen(.white),  .king(.white),
                                      .pawn(.black),   .knight(.black),
                                      .bishop(.black), .rook(.black),
                                      .queen(.black),  .king(.black)]

    #else

    /// An array of all pieces.
    public static let all: [Piece] = [.Pawn(.White),   .Knight(.White),
                                      .Bishop(.White), .Rook(.White),
                                      .Queen(.White),  .King(.White),
                                      .Pawn(.Black),   .Knight(.Black),
                                      .Bishop(.Black), .Rook(.Black),
                                      .Queen(.Black),  .King(.Black)]

    #endif

    /// An array of all white pieces.
    public static let whitePieces: [Piece] = all.filter({ $0.color.isWhite })

    /// An array of all black pieces.
    public static let blackPieces: [Piece] = all.filter({ $0.color.isBlack })

    /// Returns an array of all pieces for `color`.
    public static func pieces(for color: Color) -> [Piece] {
        return color.isWhite ? whitePieces : blackPieces
    }

    /// The piece's color.
    public var color: Color {
        get {
            #if swift(>=3)
                switch self {
                case let .pawn(color):   return color
                case let .rook(color):   return color
                case let .knight(color): return color
                case let .bishop(color): return color
                case let .king(color):   return color
                case let .queen(color):  return color
                }
            #else
                switch self {
                case let .Pawn(color):   return color
                case let .Rook(color):   return color
                case let .Knight(color): return color
                case let .Bishop(color): return color
                case let .King(color):   return color
                case let .Queen(color):  return color
                }
            #endif
        }
        set(newColor) {
            #if swift(>=3)
                switch self {
                case .pawn:   self = .pawn(newColor)
                case .rook:   self = .rook(newColor)
                case .knight: self = .knight(newColor)
                case .bishop: self = .bishop(newColor)
                case .king:   self = .king(newColor)
                case .queen:  self = .queen(newColor)
                }
            #else
                switch self {
                case .Pawn:   self = .Pawn(newColor)
                case .Rook:   self = .Rook(newColor)
                case .Knight: self = .Knight(newColor)
                case .Bishop: self = .Bishop(newColor)
                case .King:   self = .King(newColor)
                case .Queen:  self = .Queen(newColor)
                }
            #endif
        }
    }

    /// The piece's name.
    public var name: String {
        #if swift(>=3)
            switch self {
            case .pawn:   return "Pawn"
            case .knight: return "Knight"
            case .bishop: return "Bishop"
            case .rook:   return "Rook"
            case .queen:  return "Queen"
            case .king:   return "King"
            }
        #else
            switch self {
            case .Pawn:   return "Pawn"
            case .Knight: return "Knight"
            case .Bishop: return "Bishop"
            case .Rook:   return "Rook"
            case .Queen:  return "Queen"
            case .King:   return "King"
            }
        #endif
    }

    /// The character for the piece. Uppercase if white or lowercase if black.
    public var character: Character {
        #if swift(>=3)
            switch self {
            case let .pawn(color):   return color.isWhite ? "P" : "p"
            case let .knight(color): return color.isWhite ? "N" : "n"
            case let .bishop(color): return color.isWhite ? "B" : "b"
            case let .rook(color):   return color.isWhite ? "R" : "r"
            case let .queen(color):  return color.isWhite ? "Q" : "q"
            case let .king(color):   return color.isWhite ? "K" : "k"
            }
        #else
            switch self {
            case let .Pawn(color):   return color.isWhite ? "P" : "p"
            case let .Knight(color): return color.isWhite ? "N" : "n"
            case let .Bishop(color): return color.isWhite ? "B" : "b"
            case let .Rook(color):   return color.isWhite ? "R" : "r"
            case let .Queen(color):  return color.isWhite ? "Q" : "q"
            case let .King(color):   return color.isWhite ? "K" : "k"
            }
        #endif
    }

    /// The piece's relative value. Can be used to determine how valuable a piece or combination of pieces is.
    public var relativeValue: Double {
        #if swift(>=3)
            switch self {
            case .pawn:   return 1
            case .knight: return 3
            case .bishop: return 3.25
            case .rook:   return 5
            case .queen:  return 9
            case .king:   return .infinity
            }
        #else
            switch self {
            case .Pawn:   return 1
            case .Knight: return 3
            case .Bishop: return 3.25
            case .Rook:   return 5
            case .Queen:  return 9
            case .King:   return .infinity
            }
        #endif
    }

    /// The piece can be promoted. Only pawns are promotable.
    public var isPromotable: Bool {
        return isPawn
    }

    /// The piece is `Pawn`.
    public var isPawn: Bool {
        #if swift(>=3)
            if case .pawn = self { return true } else { return false }
        #else
            if case .Pawn = self { return true } else { return false }
        #endif
    }

    /// The piece `Knight`.
    public var isKnight: Bool {
        #if swift(>=3)
            if case .knight = self { return true } else { return false }
        #else
            if case .Knight = self { return true } else { return false }
        #endif
    }

    /// The piece is `Bishop`.
    public var isBishop: Bool {
        #if swift(>=3)
            if case .bishop = self { return true } else { return false }
        #else
            if case .Bishop = self { return true } else { return false }
        #endif
    }

    /// The piece is `Rook`.
    public var isRook: Bool {
        #if swift(>=3)
            if case .rook = self { return true } else { return false }
        #else
            if case .Rook = self { return true } else { return false }
        #endif
    }

    /// The piece is `Queen`.
    public var isQueen: Bool {
        #if swift(>=3)
            if case .queen = self { return true } else { return false }
        #else
            if case .Queen = self { return true } else { return false }
        #endif
    }

    /// The piece is `King`.
    public var isKing: Bool {
        #if swift(>=3)
            if case .king = self { return true } else { return false }
        #else
            if case .King = self { return true } else { return false }
        #endif
    }

    /// A textual representation of `self`.
    public var description: String {
        return "\(name)(\(color))"
    }

    /// The hash value.
    public var hashValue: Int {
        #if swift(>=3)
            switch self {
            case let .pawn(color):   return (0 << 1) | color.hashValue
            case let .knight(color): return (1 << 1) | color.hashValue
            case let .bishop(color): return (2 << 1) | color.hashValue
            case let .rook(color):   return (3 << 1) | color.hashValue
            case let .queen(color):  return (4 << 1) | color.hashValue
            case let .king(color):   return (5 << 1) | color.hashValue
            }
        #else
            switch self {
            case let .Pawn(color):   return (0 << 1) | color.hashValue
            case let .Knight(color): return (1 << 1) | color.hashValue
            case let .Bishop(color): return (2 << 1) | color.hashValue
            case let .Rook(color):   return (3 << 1) | color.hashValue
            case let .Queen(color):  return (4 << 1) | color.hashValue
            case let .King(color):   return (5 << 1) | color.hashValue
            }
        #endif
    }

    /// Create a piece from a character.
    public init?(character: Character) {
        #if swift(>=3)
            switch character {
            case "P": self = .pawn(.white)
            case "p": self = .pawn(.black)
            case "N": self = .knight(.white)
            case "n": self = .knight(.black)
            case "B": self = .bishop(.white)
            case "b": self = .bishop(.black)
            case "R": self = .rook(.white)
            case "r": self = .rook(.black)
            case "Q": self = .queen(.white)
            case "q": self = .queen(.black)
            case "K": self = .king(.white)
            case "k": self = .king(.black)
            default:
                return nil
            }
        #else
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
        #endif
    }

    /// Returns `true` if `self` can be a promotion for the piece.
    public func canPromote(_ other: Piece) -> Bool {
        #if swift(>=3)
            if case let .pawn(color) = other { return canPromote(color) } else { return false }
        #else
            if case let .Pawn(color) = other { return canPromote(color) } else { return false }
        #endif
    }

    /// Returns `true` if `self` can be a promotion for the color.
    public func canPromote(_ color: Color? = nil) -> Bool {
        if self.isPawn || self.isPawn {
            return false
        } else {
            if let color = color {
                return self.color == color
            } else {
                return true
            }
        }
    }

    /// The special character for the piece.
    public func specialCharacter(background color: Color = ._white) -> Character {
        #if swift(>=3)
            switch self {
            case let .pawn(c):   return color == c ? "♙" : "♟"
            case let .knight(c): return color == c ? "♘" : "♞"
            case let .bishop(c): return color == c ? "♗" : "♝"
            case let .rook(c):   return color == c ? "♖" : "♜"
            case let .queen(c):  return color == c ? "♕" : "♛"
            case let .king(c):   return color == c ? "♔" : "♚"
            }
        #else
            switch self {
            case let .Pawn(c):   return color == c ? "♙" : "♟"
            case let .Knight(c): return color == c ? "♘" : "♞"
            case let .Bishop(c): return color == c ? "♗" : "♝"
            case let .Rook(c):   return color == c ? "♖" : "♜"
            case let .Queen(c):  return color == c ? "♕" : "♛"
            case let .King(c):   return color == c ? "♔" : "♚"
            }
        #endif
    }

}

/// Returns `true` if both pieces are the same.
@warn_unused_result
public func == (lhs: Piece, rhs: Piece) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
