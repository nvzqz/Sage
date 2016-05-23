//
//  Piece.swift
//  Chess
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

/// A chess piece.
public enum Piece: Equatable {

    /// Pawn piece.
    case Pawn(Color)

    /// Rook piece.
    case Rook(Color)

    /// Knight piece.
    case Knight(Color)

    /// Bishop piece.
    case Bishop(Color)

    /// King piece.
    case King(Color)

    /// Queen piece.
    case Queen(Color)

    /// The piece's color.
    public var color: Color {
        get {
            switch self {
            case let Pawn(color):
                return color
            case let Rook(color):
                return color
            case let Knight(color):
                return color
            case let Bishop(color):
                return color
            case let King(color):
                return color
            case let Queen(color):
                return color
            }
        }
        set(newColor) {
            switch self {
            case Pawn:
                self = Pawn(newColor)
            case Rook:
                self = Rook(newColor)
            case Knight:
                self = Knight(newColor)
            case Bishop:
                self = Bishop(newColor)
            case King:
                self = King(newColor)
            case Queen:
                self = Queen(newColor)
            }
        }
    }

}

/// Returns `true` if both pieces are the same.
public func == (lhs: Piece, rhs: Piece) -> Bool {
    switch (lhs, rhs) {
    case let (.Pawn(cl), .Pawn(cr)):
        return cl == cr
    case let (.Rook(cl), .Rook(cr)):
        return cl == cr
    case let (.Knight(cl), .Knight(cr)):
        return cl == cr
    case let (.Bishop(cl), .Bishop(cr)):
        return cl == cr
    case let (.King(cl), .King(cr)):
        return cl == cr
    case let (.Queen(cl), .Queen(cr)):
        return cl == cr
    default:
        return false
    }
}
