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

#if os(OSX)
    import Cocoa
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

/// A chess board.
public struct Board: Hashable, SequenceType, CustomStringConvertible {

    /// A chess board space.
    public struct Space: Hashable, CustomStringConvertible {

        /// The occupying chess piece.
        public var piece: Piece?

        /// The space's file.
        public var file: File

        /// The space's rank.
        public var rank: Rank

        /// The space's location on a chess board.
        public var location: Location {
            get {
                return (file, rank)
            }
            set {
                (file, rank) = newValue
            }
        }

        /// The space's square on a chess board.
        public var square: Square {
            get {
                return Square(file: file, rank: rank)
            }
            set {
                location = newValue.location
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
            return "Space(\(name), \(piece.map({ String($0) }) ?? "nil"))"
        }

        /// The hash value.
        public var hashValue: Int {
            let pieceHash = piece?.hashValue ?? (6 << 1)
            let fileHash = file.hashValue << 4
            let rankHash = rank.hashValue << 7
            return pieceHash + fileHash + rankHash
        }

        /// Create a chess board space with a piece, file, and rank.
        public init(piece: Piece? = nil, file: File, rank: Rank) {
            self.init(piece: piece, location: (file, rank))
        }

        /// Create a chess board space with a piece and location.
        public init(piece: Piece? = nil, location: Location) {
            self.piece = piece
            (file, rank) = location
        }

        /// Create a chess board space with a piece and square.
        public init(piece: Piece? = nil, square: Square) {
            self.piece = piece
            (file, rank) = square.location
        }

        /// Clears the piece from the space and returns it.
        public mutating func clear() -> Piece? {
            let piece = self.piece
            self.piece = nil
            return piece
        }

        #if os(OSX) || os(iOS) || os(tvOS)

        internal func _view(size: CGFloat) -> _View {
            let frame = CGRect(x: CGFloat(file.index) * size,
                               y: CGFloat(rank.index) * size,
                               width: size,
                               height: size)
            var textFrame = CGRect(x: 0, y: 0, width: size, height: size)
            let fontSize = size * 0.625
            let view = _View(frame: frame)
            let str = piece.map({ String($0.specialCharacter(background: color)) }) ?? ""
            let bg: _Color = color.isWhite ? .whiteColor() : .blackColor()
            let tc: _Color = color.isWhite ? .blackColor() : .whiteColor()
            #if os(OSX)
                view.wantsLayer = true
                view.layer?.backgroundColor = bg.CGColor
                let text = NSText(frame: textFrame)
                text.alignment = .Center
                text.font = .systemFontOfSize(fontSize)
                text.string = str
                text.drawsBackground = false
                text.textColor = tc
                text.editable = false
                text.selectable = false
                view.addSubview(text)
            #else
                view.backgroundColor = color.isWhite ? .whiteColor() : .blackColor()
                let label = UILabel(frame: textFrame)
                label.textAlignment = .Center
                label.font = .systemFontOfSize(fontSize)
                label.text = str
                label.textColor = tc
                view.addSubview(label)
            #endif
            return view
        }

        #endif

    }

    /// A board side.
    public enum Side {

        /// Right side of the board.
        case Kingside

        /// Right side of the board.
        case Queenside

        /// `self` is kingside.
        public var isKingside: Bool {
            return self == .Kingside
        }

        /// `self` is queenside.
        public var isQueenside: Bool {
            return self == .Queenside
        }

    }

    /// The piece to bitboard mapping of `self`.
    internal var _bitboards: [Piece: Bitboard]

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

    /// A textual representation of `self`.
    public var description: String {
        return "Board(\(fen()))"
    }

    /// The hash value.
    public var hashValue: Int {
        return Set(self).hashValue
    }

    /// Create a chess board.
    ///
    /// - Parameter variant: The variant to populate the board for. Won't
    ///   populate if `nil`. Default is `Standard`.
    public init(variant: Variant? = .Standard) {
        if let variant = variant {
            _bitboards = [.Pawn(.White):   0x000000000000FF00,
                          .Knight(.White): 0x0000000000000042,
                          .Bishop(.White): 0x0000000000000024,
                          .Rook(.White):   0x0000000000000081,
                          .Queen(.White):  0x0000000000000008,
                          .King(.White):   0x0000000000000010,
                          .Pawn(.Black):   0x00FF000000000000,
                          .Knight(.Black): 0x4200000000000000,
                          .Bishop(.Black): 0x2400000000000000,
                          .Rook(.Black):   0x8100000000000000,
                          .Queen(.Black):  0x0800000000000000,
                          .King(.Black):   0x1000000000000000]
            if variant.isUpsideDown {
                for (piece, board) in _bitboards {
                    _bitboards[piece] = board.flippedVertically()
                }
            }
        } else {
            _bitboards = [.Pawn(.White):   0, .Knight(.White): 0,
                          .Bishop(.White): 0, .Rook(.White):   0,
                          .Queen(.White):  0, .King(.White):   0,
                          .Pawn(.Black):   0, .Knight(.Black): 0,
                          .Bishop(.Black): 0, .Rook(.Black):   0,
                          .Queen(.Black):  0, .King(.Black):   0]
        }
    }

    /// Create a chess board from a valid FEN string.
    ///
    /// - Warning: Only to be used with the board part of a full FEN string.
    public init?(fen: String) {
        func pieces(for string: String) -> [Piece?]? {
            var pieces: [Piece?] = []
            for char in string.characters {
                guard pieces.count < 8 else {
                    return nil
                }
                if let piece = Piece(character: char) {
                    pieces.append(piece)
                } else if let num = Int(String(char)) {
                    guard 1...8 ~= num else { return nil }
                    pieces += Array(count: num, repeatedValue: nil)
                } else {
                    return nil
                }
            }
            return pieces
        }
        guard !fen.characters.contains(" ") else {
            return nil
        }
        let parts = fen.characters.split("/").map(String.init)
        guard parts.count == 8 else {
            return nil
        }
        var board = Board(variant: nil)
        for (rank, part) in zip(Rank.all.reverse(), parts) {
            guard let pieces = pieces(for: part) else {
                return nil
            }
            for (file, piece) in zip(File.all, pieces) {
                board[(file, rank)] = piece
            }
        }
        self = board
    }

    /// Gets and sets a piece at `location`.
    public subscript(location: Location) -> Piece? {
        get {
            return self[Square(location: location)]
        }
        set {
            self[Square(location: location)] = newValue
        }
    }

    /// Gets and sets a piece at `square`.
    public subscript(square: Square) -> Piece? {
        get {
            for (piece, board) in _bitboards {
                if board[square] {
                    return piece
                }
            }
            return nil
        }
        set {
            for piece in _bitboards.keys {
                self[piece][square] = false
            }
            if let piece = newValue {
                if _bitboards[piece] == nil {
                    _bitboards[piece] = Bitboard()
                }
                self[piece][square] = true
            }
        }
    }

    /// Gets and sets the bitboard for `piece`.
    internal subscript(piece: Piece) -> Bitboard {
        get {
            return _bitboards[piece] ?? Bitboard()
        }
        set {
            _bitboards[piece] = newValue
        }
    }

    /// Populates `self` with with all of the pieces at their proper locations
    /// for the given chess variant.
    public mutating func populate(for variant: Variant = .Standard) {
        self = Board(variant: variant)
    }

    /// Clears all the pieces from `self`.
    public mutating func clear() {
        self = Board(variant: nil)
    }

    /// Returns `self` flipped horizontally.
    @warn_unused_result(mutable_variant="flipHorizontally")
    public func flippedHorizontally() -> Board {
        var board = self
        for (p, b) in _bitboards {
            board._bitboards[p] = b.flippedHorizontally()
        }
        return board
    }

    /// Flips `self` horizontally.
    public mutating func flipHorizontally() {
        self = flippedHorizontally()
    }

    /// Returns `self` flipped vertically.
    @warn_unused_result(mutable_variant="flipVertically")
    public func flippedVertically() -> Board {
        var board = self
        for (p, b) in _bitboards {
            board._bitboards[p] = b.flippedVertically()
        }
        return board
    }

    /// Flips `self` vertically.
    public mutating func flipVertically() {
        self = flippedVertically()
    }

    /// Returns the number of pieces for `color`, or all if `nil`.
    @warn_unused_result
    public func pieceCount(for color: Color? = nil) -> Int {
        if let color = color {
            return bitboard(for: color).count
        } else {
            return _bitboards.map({ $1.count }).reduce(0, combine: +)
        }
    }

    /// Returns the number of `piece` in `self`.
    @warn_unused_result
    public func count(of piece: Piece) -> Int {
        return bitboard(for: piece).count
    }

    /// Returns the bitboard for `piece`.
    @warn_unused_result
    public func bitboard(for piece: Piece) -> Bitboard {
        return self[piece]
    }

    /// Returns the bitboard for `color`.
    @warn_unused_result
    public func bitboard(for color: Color) -> Bitboard {
        return _bitboards.flatMap({ piece, board in
            piece.color == color ? board : nil
        }).reduce(0, combine: |)
    }

    /// Returns the spaces at `file`.
    @warn_unused_result
    public func spaces(at file: File) -> [Space] {
        return Rank.all.map { space(at: (file, $0)) }
    }

    /// Returns the spaces at `rank`.
    @warn_unused_result
    public func spaces(at rank: Rank) -> [Space] {
        return File.all.map { space(at: ($0, rank)) }
    }

    /// Returns the space at `location`.
    @warn_unused_result
    public func space(at location: Location) -> Space {
        return Space(piece: self[location], location: location)
    }

    /// Returns the square at `location`.
    @warn_unused_result
    public func space(at square: Square) -> Space {
        return Space(piece: self[square], square: square)
    }

    /// Removes a piece at `location`, and returns it.
    public mutating func removePiece(at location: Location) -> Piece? {
        return removePiece(at: Square(location: location))
    }

    /// Removes a piece at `square`, and returns it.
    public mutating func removePiece(at square: Square) -> Piece? {
        let piece = self[square]
        self[square] = nil
        return piece
    }

    /// Swaps the pieces between the two locations.
    public mutating func swap(first: Location, _ second: Location) {
        swap(Square(location: first), Square(location: second))
    }

    /// Swaps the pieces between the two squares.
    public mutating func swap(first: Square, _ second: Square) {
        (self[first], self[second]) = (self[second], self[first])
    }

    /// Returns the locations where `piece` exists.
    @warn_unused_result
    public func locations(for piece: Piece) -> [Location] {
        return squares(for: piece).map { $0.location }
    }

    /// Returns the squares where `piece` exists.
    @warn_unused_result
    public func squares(for piece: Piece) -> [Square] {
        guard let bitboard = _bitboards[piece] else {
            return []
        }
        return Square.all.filter({ bitboard[$0] })
    }

    /// Returns the square of the king for `color`.
    @warn_unused_result
    public func squareForKing(for color: Color) -> Square {
        guard let index = bitboard(for: .King(color)).lsbIndex else {
            fatalError("Board does not contain king piece")
        }
        return Square(rawValue: index)!
    }

    /// Returns the FEN string for the board.
    @warn_unused_result
    public func fen() -> String {
        func fenForRank(rank: Rank) -> String {
            var fen = ""
            var accumulator = 0
            for space in spaces(at: rank) {
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
    @warn_unused_result
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
        guard let square = Square(rawValue: _index) else {
            return nil
        }
        defer { _index += 1 }
        return _board.space(at: square)
    }

}

#if os(OSX) || os(iOS) || os(tvOS)

extension Board: CustomPlaygroundQuickLookable {

    /// Returns the `PlaygroundQuickLook` for `self`.
    public func customPlaygroundQuickLook() -> PlaygroundQuickLook {
        let spaceSize: CGFloat = 80
        let boardSize = spaceSize * 8
        let frame = CGRect(x: 0, y: 0, width: boardSize, height: boardSize)
        let view = _View(frame: frame)
        for space in self {
            view.addSubview(space._view(spaceSize))
        }
        return .View(view)
    }
        
}

#endif


/// Returns `true` if both boards are the same.
@warn_unused_result
public func == (lhs: Board, rhs: Board) -> Bool {
    return lhs._bitboards == rhs._bitboards
}

/// Returns `true` if both spaces are the same.
@warn_unused_result
public func == (lhs: Board.Space, rhs: Board.Space) -> Bool {
    return lhs.piece == rhs.piece
        && lhs.file == rhs.file
        && lhs.rank == rhs.rank
}
