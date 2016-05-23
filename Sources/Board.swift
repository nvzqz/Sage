//
//  Board.swift
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

/// A chess board.
public struct Board {

    /// A chess board space.
    public struct Space {

        /// The occupying chess piece.
        public var piece: Piece?

        /// The space's file.
        public var file: File

        /// The space's rank.
        public var rank: Rank

        /// The space's name.
        public var name: String {
            return "\(file.character)\(rank.rawValue)"
        }

        /// Create a chess board space.
        public init(piece: Piece? = nil, file: File, rank: Rank) {
            self.piece = piece
            self.file = file
            self.rank = rank
        }

        /// Clears the piece from the space and returns it.
        public mutating func clear() -> Piece? {
            let piece = self.piece
            self.piece = nil
            return piece
        }

    }

    /// The board's spaces.
    private var _spaces: [[Space]]

    /// Creates a chess board.
    ///
    /// - Parameter populate: If `true`, the board is populated. Default is `true`.
    public init(populate: Bool = true) {
        let range = 0...7
        self._spaces = range.reduce([]) { spaces, x in
            spaces + [
                range.reduce([]) {
                    $0 + [Space(file: File(column: x)!, rank: Rank(row: $1)!)]
                }
            ]
        }
        if populate {
            self.populate()
        }
    }

    /// Populates `self` with with all of the pieces at their proper locations.
    public mutating func populate() {
        self.clear()
        for x in 0...7 {
            _spaces[x][1].piece = .Pawn(.White)
            _spaces[x][6].piece = .Pawn(.Black)
        }
        for (y, color) in [(0, Color.White), (7, Color.Black)] {
            _spaces[0][y].piece = .Rook(color)
            _spaces[1][y].piece = .Knight(color)
            _spaces[2][y].piece = .Bishop(color)
            _spaces[3][y].piece = .Queen(color)
            _spaces[4][y].piece = .King(color)
            _spaces[5][y].piece = .Bishop(color)
            _spaces[6][y].piece = .Knight(color)
            _spaces[7][y].piece = .Rook(color)
        }
    }

    /// Clears all the pieces from `self`.
    public mutating func clear() {
        let range = 0...7
        for x in range {
            for y in range {
                _spaces[x][y].clear()
            }
        }
    }

}
