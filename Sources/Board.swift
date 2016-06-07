//
//  Board.swift
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

/// A chess board.
public struct Board: Equatable, SequenceType {

    /// A chess board space.
    public struct Space: Equatable, CustomStringConvertible {

        /// The occupying chess piece.
        public var piece: Piece?

        /// The space's file.
        public var file: File

        /// The space's rank.
        public var rank: Rank

        /// The space's position on a chess board.
        public var position: Position {
            get {
                return (file, rank)
            }
            set {
                (file, rank) = newValue
            }
        }

        /// The space's color.
        public var color: Color {
            return (file.index % 2 != rank.index % 2) ? .White : .Black
        }

        /// The space's name.
        public var name: String {
            return "\(file.character)\(rank.rawValue)"
        }

        /// A textual representation of `self`.
        public var description: String {
            return "Space(\"\(name)\" \(piece.map({ String($0) }) ?? "nil"))"
        }

        /// Create a chess board space with a piece, file, and rank.
        public init(piece: Piece? = nil, file: File, rank: Rank) {
            self.init(piece: piece, position: (file, rank))
        }

        /// Create a chess board space with a piece and position.
        public init(piece: Piece? = nil, position: Position) {
            self.piece = piece
            (file, rank) = position
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

    /// The board's pieces.
    public var pieces: [Piece] {
        return self.flatMap({ $0.piece })
    }

    /// The board's white pieces.
    public var whitePieces: [Piece] {
        return pieces.filter({ $0.color.isWhite })
    }

    /// The board's black pieces.
    public var blackPieces: [Piece] {
        return pieces.filter({ $0.color.isBlack })
    }

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

    /// Gets and sets a piece at the position.
    public subscript(position: Position) -> Piece? {
        get {
            return spaceAt(position).piece
        }
        set {
            _spaces[position.file.index][position.rank.index].piece = newValue
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

    /// Returns the spaces at the file.
    @warn_unused_result
    public func spacesAtFile(file: File) -> [Space] {
        return _spaces[file.index]
    }

    /// Returns the spaces at the rank.
    @warn_unused_result
    public func spacesAtRank(rank: Rank) -> [Space] {
        return _spaces.map({ $0[rank.index] })
    }

    /// Returns the space at the file and rank.
    @warn_unused_result
    public func spaceAt(position: Position) -> Space {
        return _spaces[position.file.index][position.rank.index]
    }

    /// Removes a piece at the file and rank, and returns it.
    public mutating func removePieceAt(position: Position) -> Piece? {
        let piece = self[position]
        self[position] = nil
        return piece
    }

    /// Swaps the pieces between the two positions.
    public mutating func swap(first: Position, _ second: Position) {
        (self[first], self[second]) = (self[second], self[first])
    }

    /// Returns the FEN string for the board.
    public func fen() -> String {
        func fenForRank(rank: Rank) -> String {
            var fen = ""
            var accumulator = 0
            for space in spacesAtRank(rank) {
                if let piece = space.piece {
                    if accumulator > 0 {
                        fen += String(accumulator)
                        accumulator = 0
                    }
                    fen += String(piece.character)
                } else {
                    accumulator += 1
                    if space.file == .H {
                        fen += String(accumulator)
                    }
                }
            }
            return fen
        }
        return Rank.all.reverse().map(fenForRank).joinWithSeparator("/")
    }

    /// Returns a generator over the spaces of the board.
    ///
    /// - Complexity: O(1).
    public func generate() -> BoardGenerator {
        return BoardGenerator(self)
    }

}

/// A generator for the spaces of a chess board.
public struct BoardGenerator: GeneratorType {

    private let _board: Board
    private var _index: Int

    private init(_ board: Board) {
        self._board = board
        self._index = 0
    }

    /// Advances to the next space on the board.
    public mutating func next() -> Board.Space? {
        guard _index < 64 else { return nil }
        defer { _index += 1 }
        return _board._spaces[_index % 8][_index / 8]
    }

}

/// Returns `true` if both boards are the same.
@warn_unused_result
public func == (lhs: Board, rhs: Board) -> Bool {
    for (ls, rs) in zip(lhs._spaces, rhs._spaces) {
        guard ls == rs else {
            return false
        }
    }
    return true
}

/// Returns `true` if both spaces are the same.
@warn_unused_result
public func == (lhs: Board.Space, rhs: Board.Space) -> Bool {
    return lhs.piece == rhs.piece
        && lhs.file == rhs.file
        && lhs.rank == rhs.rank
}
