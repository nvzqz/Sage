//
//  Game.swift
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

/// A chess game.
public final class Game {

    /// A chess game mode.
    public enum Mode {

        /// A game between two humans.
        case HumanVsHuman

        /// A game between a human and a computer.
        case HumanVsComputer

        /// A game between two computers.
        case ComputerVsComputer

    }

    /// A chess game outcome.
    public enum Outcome: Hashable, CustomStringConvertible {

        /// A win for a `Color`.
        case Win(Color)

        /// A draw.
        case Draw

        /// The hash value.
        public var hashValue: Int {
            return winColor?.hashValue ?? 2
        }

        /// A textual representation of `self`.
        public var description: String {
            switch self {
            case .Win(.White):
                return "1-0"
            case .Win(.Black):
                return "0-1"
            case .Draw:
                return "1/2-1/2"
            }
        }

        /// The color for the winning player.
        public var winColor: Color? {
            guard case .Win(let color) = self else {
                return nil
            }
            return color
        }

        /// `self` is a win.
        public var isWin: Bool {
            if case .Win = self {
                return true
            } else {
                return false
            }
        }

        /// `self` is a draw.
        public var isDraw: Bool {
            return !isWin
        }

        /// Create an outcome from `string`.
        public init?(_ string: String) {
            switch string {
            case "1-0":
                self = .Win(.White)
            case "0-1":
                self = .Win(.Black)
            case "1/2-1/2":
                self = .Draw
            default:
                return nil
            }
        }

        /// The point value for a player. Can be 1 for win, 0.5 for draw, or
        /// 0 for loss.
        public func valueFor(player color: Color) -> Double {
            return winColor.map({ $0 == color ? 1 : 0 }) ?? 0.5
        }

    }

    /// A game position.
    public struct Position: Equatable, CustomStringConvertible {

        /// The board for the position.
        public var board: Board

        /// The active player turn.
        public var playerTurn: PlayerTurn

        /// The castling rights.
        public var castlingRights: CastlingRights

        /// The en passant target location.
        public var enPassantTarget: Square?

        /// The halfmove number.
        public var halfmoves: UInt

        /// The fullmove clock.
        public var fullmoves: UInt

        /// A textual representation of `self`.
        public var description: String {
            return "Position(\(fen()))"
        }

        /// Create a position.
        public init(board: Board = Board(),
                    playerTurn: PlayerTurn = .White,
                    castlingRights: CastlingRights = .all,
                    enPassantTarget: Square? = nil,
                    halfmoves: UInt = 0,
                    fullmoves: UInt = 1) {
            self.board = board
            self.playerTurn = playerTurn
            self.castlingRights = castlingRights
            self.enPassantTarget = enPassantTarget
            self.halfmoves = halfmoves
            self.fullmoves = fullmoves
        }

        /// Create a position for a game.
        public init(game: Game) {
            self.board = game.board
            self.playerTurn = game.playerTurn
            self.castlingRights = game.castlingRights
            self.enPassantTarget = game.enPassantTarget
            self.halfmoves = game.halfmoves
            self.fullmoves = game.fullmoves
        }

        /// Create a position from a valid FEN string.
        public init?(fen: String) {
            let parts = fen.characters.split(" ").map(String.init)
            guard parts.count == 6,
                let board = Board(fen: parts[0])
                where parts[1].characters.count == 1,
                let playerTurn = parts[1].characters.first.flatMap(Color.init),
                let rights = CastlingRights(string: parts[2]),
                let halfmoves = UInt(parts[4]),
                let fullmoves = UInt(parts[5]) where fullmoves > 0
                else { return nil }
            var target: Square? = nil
            let targetStr = parts[3]
            let targetChars = targetStr.characters
            if targetChars.count == 2 {
                guard let square = Square.init(targetStr) else {
                    return nil
                }
                target = square
            } else {
                guard targetStr == "-" else {
                    return nil
                }
            }
            self.init(board: board,
                      playerTurn: playerTurn,
                      castlingRights: rights,
                      enPassantTarget: target,
                      halfmoves: halfmoves,
                      fullmoves: fullmoves)
        }

        /// Returns the FEN string for the position.
        @warn_unused_result
        public func fen() -> String {
            return board.fen()
                + " \(playerTurn.isWhite ? "w" : "b") \(castlingRights) "
                + (enPassantTarget.map({ "\($0)".lowercaseString }) ?? "-")
                + " \(halfmoves) \(fullmoves)"
        }

    }

    /// A move history record.
    private typealias _MoveRecord = (move: Move, piece: Piece, capture: Piece?)

    /// An undo history record.
    private typealias _UndoRecord = (move: Move, promotion: Piece?)

    /// A player turn.
    public typealias PlayerTurn = Color

    /// All of the conducted moves in the game.
    private var _moveHistory: [_MoveRecord]

    /// All of the undone moves in the game.
    private var _undoHistory: [_UndoRecord]

    /// The game's board.
    public private(set) var board: Board

    /// The current player's turn.
    public private(set) var playerTurn: PlayerTurn

    /// The castling rights.
    public private(set) var castlingRights: CastlingRights

    /// The game's mode.
    public var mode: Mode

    /// The game's variant.
    public let variant: Variant

    /// All of the moves played in the game.
    public var playedMoves: [Move] {
        return _moveHistory.map({ $0.move })
    }

    /// The amount of moves executed.
    public var moveCount: Int {
        return _moveHistory.count
    }

    /// The current fullmove number.
    public var fullmoves: UInt {
        return 1 + (UInt(moveCount) / 2)
    }

    /// The current halfmove clock.
    public var halfmoves: UInt {
        var n: UInt = 0
        for (_, piece, capture) in _moveHistory.reverse() {
            if capture != nil { break }
            if case .Pawn = piece { break }
            n += 1
        }
        return n
    }

    /// The target move location for an en passant.
    public var enPassantTarget: Square? {
        guard let (move, piece, _) = _moveHistory.last, case .Pawn = piece else {
            return nil
        }
        guard abs(move.rankChange) == 2 else {
            return nil
        }
        return Square(file: move.start.file, rank: move.isUpward ? .Three : .Six)
    }

    /// The current position for `self`.
    public var position: Position {
        return Position(game: self)
    }

    /// Creates a new chess game.
    ///
    /// - Parameter mode: The game's mode. Default is `HumanVsHuman`.
    public init(mode: Mode = .HumanVsHuman, variant: Variant = .Standard) {
        self._moveHistory = []
        self._undoHistory = []
        self.board = Board(variant: variant)
        self.playerTurn = .White
        self.castlingRights = .all
        self.mode = mode
        self.variant = variant
    }

    /// Returns the captured pieces for a color, or for all if color is `nil`.
    @warn_unused_result
    public func capturedPieces(for color: Color? = nil) -> [Piece] {
        let pieces = _moveHistory.flatMap({ $0.capture })
        if let color = color {
            return pieces.filter({ $0.color == color })
        } else {
            return pieces
        }
    }

    /// Returns the available moves for the current player.
    @warn_unused_result
    public func availableMoves() -> [Move] {
        return Array(Square.all.map(movesForPiece).flatten())
    }

    /// Returns the moves bitboard currently available for the piece at `square`, if any.
    @warn_unused_result
    public func movesBitboardForPiece(at square: Square) -> Bitboard {
        guard let piece = board[square] where piece.color == playerTurn else {
            return 0
        }
        let playerBitboard = board.bitboard(for: playerTurn)
        let enemyBitboard = board.bitboard(for: playerTurn.inverse())
        let allBitboard = playerBitboard | enemyBitboard
        let emptyBitboard = ~allBitboard
        let squareBitboard = Bitboard(square: square)

        var movesBitboard: Bitboard = 0
        let attacks = square.attacks(for: piece, stoppers: allBitboard)

        if case .Pawn = piece {
            let enPassant = enPassantTarget.map({ Bitboard(square: $0) }) ?? 0
            let pushes = squareBitboard._pawnPushes(for: playerTurn,
                                                    empty: emptyBitboard)
            let doublePushes = (squareBitboard & Bitboard(startFor: piece))
                ._pawnPushes(for: playerTurn, empty: emptyBitboard)
                ._pawnPushes(for: playerTurn, empty: emptyBitboard)
            movesBitboard |= pushes | doublePushes
                | (attacks & enemyBitboard)
                | (attacks & enPassant)
        } else {
            movesBitboard |= attacks & ~playerBitboard
        }

        if case .King = piece where squareBitboard == Bitboard(startFor: piece) {
            for option in castlingRights {
                if option.color == playerTurn && allBitboard & option.emptySquares == 0 {
                    movesBitboard |= Bitboard(square: option.castleSquare)
                }
            }
        }

        return movesBitboard
    }

    /// Returns the moves currently available for the piece at `square`, if any.
    @warn_unused_result
    public func movesForPiece(at square: Square) -> [Move] {
        return movesBitboardForPiece(at: square).moves(from: square)
    }

    /// Returns the moves currently available for the piece at `location`, if any.
    @warn_unused_result
    public func movesForPiece(at location: Location) -> [Move] {
        return movesForPiece(at: Square(location: location))
    }

    /// Returns `true` if the move is valid.
    @warn_unused_result
    public func isValidMove(move: Move) -> Bool {
        let moves = movesBitboardForPiece(at: move.start)
        return moves & Bitboard(square: move.end) != 0
    }

    /// Executes a move without checking the validity of the move.
    private func _executeMove(move: Move, promotion: (() -> Piece)?) throws {
        let piece = board[move.start]!
        var endPiece = piece
        var capture = board[move.end]
        var captureSquare = move.end
        if case .Pawn = piece {
            if move.end.rank == Rank(endFor: playerTurn) {
                let promotion = promotion?()
                if let p = promotion {
                    guard p.color == playerTurn else {
                        throw MoveExecutionError.InvalidPromotionPiece(p)
                    }
                }
                endPiece = promotion ?? .Queen(playerTurn)
            } else if move.end == enPassantTarget {
                capture = Piece.Pawn(playerTurn.inverse())
                captureSquare = Square(file: move.end.file, rank: move.start.rank)
            }
        } else if case .Rook = piece {
            switch move.start {
            case .A1: castlingRights.remove(.WhiteQueenside)
            case .H1: castlingRights.remove(.WhiteKingside)
            case .A8: castlingRights.remove(.BlackQueenside)
            case .H8: castlingRights.remove(.BlackKingside)
            default:
                break
            }
        } else if case .King = piece {
            for option in castlingRights where option.color == playerTurn {
                castlingRights.remove(option)
            }
            if abs(move.fileChange) == 2 {
                let (old, new) = move._castleSquares()
                let rook = Piece.Rook(playerTurn)
                board[rook][old] = false
                board[rook][new] = true
            }
        }
        _moveHistory.append((move, piece, capture))
        if let capture = capture {
            board[capture][captureSquare] = false
        }
        board[piece][move.start] = false
        board[endPiece][move.end] = true
        playerTurn.invert()
    }

    /// Executes the move or throws on error.
    public func executeMove(move: Move, promotion: (() -> Piece)? =  nil) throws {
        guard isValidMove(move) else { throw MoveExecutionError.IllegalMove }
        try _executeMove(move, promotion: promotion)
    }

    /// Executes the move or throws on error.
    public func executeMove(move: Move, promotion: Piece) throws {
        try executeMove(move, promotion: { promotion })
    }

    /// Undoes the previous move and returns it, if any.
    public func undoMove() -> Move? {
        guard let (move, piece, capture) = _moveHistory.popLast() else {
            return nil
        }
        var captureSquare = move.end
        var promotion: Piece? = nil
        if case .Pawn = piece {
            if move.end == enPassantTarget {
                captureSquare = Square(file: move.end.file, rank: move.start.rank)
            } else if move.end.rank == Rank(endFor: playerTurn.inverse()) {
                promotion = board[move.end]
            }
        } else if case .King = piece where abs(move.fileChange) == 2 {
            let (old, new) = move._castleSquares()
            let rook = Piece.Rook(playerTurn.inverse())
            board[rook][old] = true
            board[rook][new] = false
        }
        _undoHistory.append((move, promotion))
        if let capture = capture {
            board[capture][captureSquare] = true
        }
        board[piece][move.end] = false
        board[piece][move.start] = true
        playerTurn.invert()
        return move
    }

    /// Redoes the previous undone move and returns it, if any.
    public func redoMove() -> Move? {
        guard let (move, promotion) = _undoHistory.popLast() else {
            return nil
        }
        try! _executeMove(move, promotion: promotion.map { p in { p } })
        return move
    }

}

private typealias _MoveResult = _Result<Piece, MoveExecutionError>

/// An error in move execution.
public enum MoveExecutionError: ErrorType {

    /// Attempted illegal move.
    case IllegalMove

    /// Could not promote with a piece.
    case InvalidPromotionPiece(Piece)

}

/// Returns `true` if the outcomes are the same.
public func == (lhs: Game.Outcome, rhs: Game.Outcome) -> Bool {
    return lhs.winColor == rhs.winColor
}

/// Returns `true` if the positions are the same.
public func == (lhs: Game.Position, rhs: Game.Position) -> Bool {
    return lhs.playerTurn == rhs.playerTurn
        && lhs.castlingRights == rhs.castlingRights
        && lhs.halfmoves == rhs.halfmoves
        && lhs.fullmoves == rhs.fullmoves
        && {
            switch (lhs.enPassantTarget, rhs.enPassantTarget) {
            case let (lhsTarget?, rhsTarget?):
                return lhsTarget == rhsTarget
            case (.None, .None):
                return true
            default:
                return false
            }
        }()
        && lhs.board == rhs.board
}
