//
//  Board.swift
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

#if os(OSX)
    import Cocoa
#elseif os(iOS) || os(tvOS)
    import UIKit
#endif

/// A chess board used to map `Square`s to `Piece`s.
///
/// Pieces map to separate instances of `Bitboard` which can be retreived with `bitboard(for:)`.
public struct Board: Hashable, CustomStringConvertible {

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
            return (file.index & 1 != rank.index & 1) ? ._white : ._black
        }

        /// The space's name.
        public var name: String {
            return "\(file.character)\(rank.rawValue)"
        }

        /// A textual representation of `self`.
        public var description: String {
            return "Space(\(name), \(piece._altDescription)"
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
            #if os(OSX)
                let rectY = CGFloat(rank.index) * size
            #else
                let rectY = CGFloat(7 - rank.index) * size
            #endif
            let frame = CGRect(x: CGFloat(file.index) * size,
                               y: rectY,
                               width: size,
                               height: size)
            var textFrame = CGRect(x: 0, y: 0, width: size, height: size)
            let fontSize = size * 0.625
            let view = _View(frame: frame)
            let str = piece.map({ String($0.specialCharacter(background: color)) }) ?? ""
            #if swift(>=3)
                let white = _Color.white()
                let black = _Color.black()
            #else
                let white = _Color.whiteColor()
                let black = _Color.blackColor()
            #endif
            let bg: _Color = color.isWhite ? white : black
            let tc: _Color = color.isWhite ? black : white
            #if os(OSX)
                view.wantsLayer = true
                let text = NSText(frame: textFrame)
                #if swift(>=3)
                    view.layer?.backgroundColor = bg.cgColor
                    text.alignment = .center
                    text.font = .systemFont(ofSize: fontSize)
                    text.isEditable = false
                    text.isSelectable = false
                #else
                    view.layer?.backgroundColor = bg.CGColor
                    text.alignment = .Center
                    text.font = .systemFontOfSize(fontSize)
                    text.editable = false
                    text.selectable = false
                #endif
                text.string = str
                text.drawsBackground = false
                text.textColor = tc
                view.addSubview(text)
            #else
                view.backgroundColor = bg
                let label = UILabel(frame: textFrame)
                #if swift(>=3)
                    label.textAlignment = .center
                    label.font = .systemFont(ofSize: fontSize)
                #else
                    label.textAlignment = .Center
                    label.font = .systemFontOfSize(fontSize)
                #endif
                label.text = str
                label.textColor = tc
                view.addSubview(label)
            #endif
            return view
        }

        #endif

    }

    /// An iterator for `Board` used as a base for both `Iterator` and `Generator`.
    private struct _MutualIterator {

        let _board: Board

        var _index: Int

        init(_ board: Board) {
            self._board = board
            self._index = 0
        }

        mutating func next() -> Board.Space? {
            guard let square = Square(rawValue: _index) else {
                return nil
            }
            defer { _index += 1 }
            return _board.space(at: square)
        }

    }

    #if swift(>=3)

    /// An iterator for the spaces of a chess board.
    public struct Iterator: IteratorProtocol {

        private var _base: _MutualIterator

        /// Advances to the next space on the board and returns it.
        public mutating func next() -> Board.Space? {
            return _base.next()
        }

    }

    #else

    /// A generator for the spaces of a chess board.
    public struct Generator: GeneratorType {

        private var _base: _MutualIterator

        /// Advances to the next space on the board and returns it.
        public mutating func next() -> Board.Space? {
            return _base.next()
        }

    }

    #endif

    /// A board side.
    public enum Side {

        #if swift(>=3)

        /// Right side of the board.
        case kingside

        /// Right side of the board.
        case queenside

        #else

        /// Right side of the board.
        case Kingside

        /// Right side of the board.
        case Queenside

        #endif

        /// `self` is kingside.
        public var isKingside: Bool {
            #if swift(>=3)
                return self == .kingside
            #else
                return self == .Kingside
            #endif
        }

        /// `self` is queenside.
        public var isQueenside: Bool {
            #if swift(>=3)
                return self == .queenside
            #else
                return self == .Queenside
            #endif
        }

    }

    /// The bitboards of `self`.
    internal var _bitboards: ContiguousArray<Bitboard>

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

    /// A bitboard for the occupied spaces of `self`.
    public var occupiedSpaces: Bitboard {
        return _bitboards.reduce(0, combine: |)
    }

    /// A bitboard for the empty spaces of `self`.
    public var emptySpaces: Bitboard {
        return ~occupiedSpaces
    }

    /// A textual representation of `self`.
    public var description: String {
        return "Board(\(fen()))"
    }

    /// The hash value.
    public var hashValue: Int {
        return Set(self).hashValue
    }

    /// An ASCII art representation of `self`.
    ///
    /// The ASCII representation for the starting board:
    ///
    /// ```
    ///   +-----------------+
    /// 8 | r n b q k b n r |
    /// 7 | p p p p p p p p |
    /// 6 | . . . . . . . . |
    /// 5 | . . . . . . . . |
    /// 4 | . . . . . . . . |
    /// 3 | . . . . . . . . |
    /// 2 | P P P P P P P P |
    /// 1 | R N B Q K B N R |
    ///   +-----------------+
    ///     a b c d e f g h
    /// ```
    public var ascii: String {
        let edge = "  +-----------------+\n"
        var result = edge
        #if swift(>=3)
            let reversed = Rank.all.reversed()
        #else
            let reversed = Rank.all.reverse()
        #endif
        for rank in reversed {
            let strings = File.all.map({ file in "\(self[(file, rank)]?.character ?? ".")" })
            #if swift(>=3)
                let str = strings.joined(separator: " ")
            #else
                let str = strings.joinWithSeparator(" ")
            #endif
            result += "\(rank) | \(str) |\n"
        }
        result += "\(edge)    a b c d e f g h  "
        return result
    }

    /// Create a chess board.
    ///
    /// - parameter variant: The variant to populate the board for. Won't populate if `nil`. Default is `Standard`.
    public init(variant: Variant? = ._standard) {
        #if swift(>=3)
            _bitboards = ContiguousArray(repeating: 0, count: 12)
        #else
            _bitboards = ContiguousArray(count: 12, repeatedValue: 0)
        #endif
        if let variant = variant {
            for piece in Piece.all {
                _bitboards[piece.hashValue] = Bitboard(startFor: piece)
            }
            if variant.isUpsideDown {
                for index in _bitboards.indices {
                    _bitboards[index].flipVertically()
                }
            }
        }
    }

    /// Create a chess board from a valid FEN string.
    ///
    /// - Warning: Only to be used with the board part of a full FEN string.
    ///
    /// - seealso: [FEN (Wikipedia)](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation),
    ///            [FEN (Chess Programming Wiki)](https://chessprogramming.wikispaces.com/Forsyth-Edwards+Notation)
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
                    #if swift(>=3)
                        pieces += Array(repeating: nil, count: num)
                    #else
                        pieces += Array(count: num, repeatedValue: nil)
                    #endif
                } else {
                    return nil
                }
            }
            return pieces
        }
        guard !fen.characters.contains(" ") else {
            return nil
        }
        #if swift(>=3)
            let parts = fen.characters.split(separator: "/").map(String.init)
            let ranks = Rank.all.reversed()
        #else
            let parts = fen.characters.split("/").map(String.init)
            let ranks = Rank.all.reverse()
        #endif
        guard parts.count == 8 else {
            return nil
        }
        var board = Board(variant: nil)
        for (rank, part) in zip(ranks, parts) {
            guard let pieces = pieces(for: part) else {
                return nil
            }
            for (file, piece) in zip(File.all, pieces) {
                board[(file, rank)] = piece
            }
        }
        self = board
    }

    /// Create a chess board from arrays of piece characters.
    ///
    /// Returns `nil` if a piece can't be initialized from a character. Characters beyond the 8x8 area are ignored.
    /// Empty spaces are denoted with a whitespace or period.
    ///
    /// ```swift
    /// Board(pieces: [["r", "n", "b", "q", "k", "b", "n", "r"],
    ///                ["p", "p", "p", "p", "p", "p", "p", "p"],
    ///                [" ", " ", " ", " ", " ", " ", " ", " "],
    ///                [" ", " ", " ", " ", " ", " ", " ", " "],
    ///                [" ", " ", " ", " ", " ", " ", " ", " "],
    ///                [" ", " ", " ", " ", " ", " ", " ", " "],
    ///                ["P", "P", "P", "P", "P", "P", "P", "P"],
    ///                ["R", "N", "B", "Q", "K", "B", "N", "R"]])
    /// ```
    public init?(pieces: [[Character]]) {
        self.init(variant: nil)
        for rankIndex in pieces.indices {
            guard let rank = Rank(index: rankIndex)?.opposite() else { break }
            for fileIndex in pieces[rankIndex].indices {
                guard let file = File(index: fileIndex) else { break }
                let pieceChar = pieces[rankIndex][fileIndex]
                if pieceChar != " " && pieceChar != "." {
                    guard let piece = Piece(character: pieceChar) else { return nil }
                    self[(file, rank)] = piece
                }
            }
        }
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
            for index in _bitboards.indices {
                if _bitboards[index][square] {
                    return Piece(value: index)
                }
            }
            return nil
        }
        set {
            for index in _bitboards.indices {
                _bitboards[index][square] = false
            }
            if let piece = newValue {
                self[piece][square] = true
            }
        }
    }

    /// Gets and sets the bitboard for `piece`.
    internal subscript(piece: Piece) -> Bitboard {
        get {
            return _bitboards[piece.hashValue]
        }
        set {
            _bitboards[piece.hashValue] = newValue
        }
    }

    /// Returns `self` flipped horizontally.
    public func flippedHorizontally() -> Board {
        var board = self
        for index in _bitboards.indices {
            board._bitboards[index].flipHorizontally()
        }
        return board
    }

    /// Returns `self` flipped vertically.
    public func flippedVertically() -> Board {
        var board = self
        for index in _bitboards.indices {
            board._bitboards[index].flipVertically()
        }
        return board
    }

    /// Clears all the pieces from `self`.
    public mutating func clear() {
        self = Board(variant: nil)
    }

    /// Populates `self` with with all of the pieces at their proper locations for the given chess variant.
    public mutating func populate(for variant: Variant = ._standard) {
        self = Board(variant: variant)
    }

    /// Flips `self` horizontally.
    public mutating func flipHorizontally() {
        self = flippedHorizontally()
    }

    /// Flips `self` vertically.
    public mutating func flipVertically() {
        self = flippedVertically()
    }

    /// Returns the number of pieces for `color`, or all if `nil`.
    public func pieceCount(for color: Color? = nil) -> Int {
        if let color = color {
            return bitboard(for: color).count
        } else {
            return _bitboards.map({ $0.count }).reduce(0, combine: +)
        }
    }

    /// Returns the number of `piece` in `self`.
    public func count(of piece: Piece) -> Int {
        return bitboard(for: piece).count
    }

    /// Returns the bitboard for `piece`.
    public func bitboard(for piece: Piece) -> Bitboard {
        return self[piece]
    }

    /// Returns the bitboard for `color`.
    public func bitboard(for color: Color) -> Bitboard {
        return Piece.pieces(for: color).map({ self[$0] }).reduce(0, combine: |)
    }

    /// Returns the attackers to `square` corresponding to `color`.
    ///
    /// - parameter square: The `Square` being attacked.
    /// - parameter color: The `Color` of the attackers.
    public func attackers(to square: Square, color: Color) -> Bitboard {
        let all = occupiedSpaces
        let attackPieces = Piece.pieces(for: color)
        let playerPieces = Piece.pieces(for: color.inverse())
        let attacks = playerPieces.map({ piece in
            square.attacks(for: piece, stoppers: all)
        })
        let queens = (attacks[2] | attacks[3]) & self[Piece(queen: color)]
        return zip(attackPieces, attacks)
            .map({ self[$0] & $1 })
            .reduce(queens, combine: |)
    }

    /// Returns the attackers to the king for `color`.
    ///
    /// - parameter color: The `Color` of the potentially attacked king.
    ///
    /// - returns: A bitboard of all attackers, or 0 if the king does not exist or if there are no pieces attacking the
    ///            king.
    public func attackersToKing(for color: Color) -> Bitboard {
        guard let square = squareForKing(for: color) else {
            return 0
        }
        return attackers(to: square, color: color.inverse())
    }

    /// Returns `true` if the king for `color` is in check.
    public func kingIsChecked(for color: Color) -> Bool {
        return attackersToKing(for: color) != 0
    }

    /// Returns the spaces at `file`.
    public func spaces(at file: File) -> [Space] {
        return Rank.all.map { space(at: (file, $0)) }
    }

    /// Returns the spaces at `rank`.
    public func spaces(at rank: Rank) -> [Space] {
        return File.all.map { space(at: ($0, rank)) }
    }

    /// Returns the space at `location`.
    public func space(at location: Location) -> Space {
        return Space(piece: self[location], location: location)
    }

    /// Returns the square at `location`.
    public func space(at square: Square) -> Space {
        return Space(piece: self[square], square: square)
    }

    #if swift(>=3)

    /// Removes a piece at `square`, and returns it.
    @discardableResult
    public mutating func removePiece(at square: Square) -> Piece? {
        if let piece = self[square] {
            self[piece][square] = false
            return piece
        } else {
            return nil
        }
    }

    /// Removes a piece at `location`, and returns it.
    @discardableResult
    public mutating func removePiece(at location: Location) -> Piece? {
        return removePiece(at: Square(location: location))
    }

    #else

    /// Removes a piece at `square`, and returns it.
    public mutating func removePiece(at square: Square) -> Piece? {
        if let piece = self[square] {
            self[piece][square] = false
            return piece
        } else {
            return nil
        }
    }

    /// Removes a piece at `location`, and returns it.
    public mutating func removePiece(at location: Location) -> Piece? {
        return removePiece(at: Square(location: location))
    }

    #endif

    /// Swaps the pieces between the two locations.
    public mutating func swap(_ first: Location, _ second: Location) {
        swap(Square(location: first), Square(location: second))
    }

    /// Swaps the pieces between the two squares.
    public mutating func swap(_ first: Square, _ second: Square) {
        switch (self[first], self[second]) {
        case let (firstPiece?, secondPiece?):
            self[firstPiece].swap(first, second)
            self[secondPiece].swap(first, second)
        case let (firstPiece?, nil):
            self[firstPiece].swap(first, second)
        case let (nil, secondPiece?):
            self[secondPiece].swap(first, second)
        default:
            break
        }
    }

    /// Returns the locations where `piece` exists.
    public func locations(for piece: Piece) -> [Location] {
        return bitboard(for: piece).map({ $0.location })
    }

    /// Returns the squares where `piece` exists.
    public func squares(for piece: Piece) -> [Square] {
        return Array(bitboard(for: piece))
    }

    /// Returns the squares where pieces for `color` exist.
    public func squares(for color: Color) -> [Square] {
        return Array(bitboard(for: color))
    }

    /// Returns the square of the king for `color`, if any.
    public func squareForKing(for color: Color) -> Square? {
        return bitboard(for: Piece(king: color)).lsbSquare
    }

    /// Returns `true` if `self` contains `piece`.
    public func contains(_ piece: Piece) -> Bool {
        return !self[piece].isEmpty
    }

    /// Returns the FEN string for the board.
    ///
    /// - seealso: [FEN (Wikipedia)](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation),
    ///            [FEN (Chess Programming Wiki)](https://chessprogramming.wikispaces.com/Forsyth-Edwards+Notation)
    public func fen() -> String {
        func fen(forRank rank: Rank) -> String {
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
                    #if swift(>=3)
                        let h = File.h
                    #else
                        let h = File.H
                    #endif
                    if space.file == h {
                        fen += String(accumulator)
                    }
                }
            }
            return fen
        }
        #if swift(>=3)
            return Rank.all.reversed().map(fen).joined(separator: "/")
        #else
            return Rank.all.reverse().map(fen).joinWithSeparator("/")
        #endif
    }

}

#if swift(>=3)

extension Board: Sequence {
    /// Returns an iterator over the spaces of the board.
    public func makeIterator() -> Iterator {
        return Iterator(_base: _MutualIterator(self))
    }
}

#else

extension Board: SequenceType {
    /// Returns a generator over the spaces of the board.
    ///
    /// - complexity: O(1).
    public func generate() -> Generator {
        return Generator(_base: _MutualIterator(self))
    }
}

#endif

#if os(OSX) || os(iOS) || os(tvOS)

extension Board: CustomPlaygroundQuickLookable {

    /// Returns the `PlaygroundQuickLook` for `self`.
    private var _customPlaygroundQuickLook: PlaygroundQuickLook {
        let spaceSize: CGFloat = 80
        let boardSize = spaceSize * 8
        let frame = CGRect(x: 0, y: 0, width: boardSize, height: boardSize)
        let view = _View(frame: frame)
        #if swift(>=3)
            for space in self {
                view.addSubview(space._view(size: spaceSize))
            }
            return .view(view)
        #else
            for space in self {
                view.addSubview(space._view(spaceSize))
            }
            return .View(view)
        #endif
    }

    #if swift(>=3)
    /// A custom playground quick look for this instance.
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return _customPlaygroundQuickLook
    }
    #else
    /// Returns the `PlaygroundQuickLook` for `self`.
    public func customPlaygroundQuickLook() -> PlaygroundQuickLook {
        return _customPlaygroundQuickLook
    }
    #endif

}

#endif

/// Returns `true` if both boards are the same.
public func == (lhs: Board, rhs: Board) -> Bool {
    return lhs._bitboards == rhs._bitboards
}

/// Returns `true` if both spaces are the same.
public func == (lhs: Board.Space, rhs: Board.Space) -> Bool {
    return lhs.piece == rhs.piece
        && lhs.file == rhs.file
        && lhs.rank == rhs.rank
}
