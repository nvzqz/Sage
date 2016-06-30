//
//  Game.swift
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

        /// The point value for a player. Can be 1 for win, 0.5 for draw, or 0 for loss.
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
        ///
        /// - SeeAlso: [FEN (Wikipedia)](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation),
        ///            [FEN (Chess Programming Wiki)](https://chessprogramming.wikispaces.com/Forsyth-Edwards+Notation)
        public init?(fen: String) {
            let parts = fen.characters.split(" ").map(String.init)
            guard parts.count == 6,
                let board = Board(fen: parts[0])
                where parts[1].characters.count == 1,
                let playerTurn = parts[1].characters.first.flatMap(Color.init),
                rights = CastlingRights(string: parts[2]),
                halfmoves = UInt(parts[4]),
                fullmoves = UInt(parts[5]) where fullmoves > 0
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
        ///
        /// - SeeAlso: [FEN (Wikipedia)](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation),
        ///            [FEN (Chess Programming Wiki)](https://chessprogramming.wikispaces.com/Forsyth-Edwards+Notation)
        @warn_unused_result
        public func fen() -> String {
            return board.fen()
                + " \(playerTurn.isWhite ? "w" : "b") \(castlingRights) "
                + (enPassantTarget.map({ "\($0)".lowercaseString }) ?? "-")
                + " \(halfmoves) \(fullmoves)"
        }

    }

    /// A player turn.
    public typealias PlayerTurn = Color

    /// All of the conducted moves in the game.
    private var _moveHistory: [(move: Move, piece: Piece, capture: Piece?, kingAttackers: Bitboard, halfmoves: UInt)]

    /// All of the undone moves in the game.
    private var _undoHistory: [(move: Move, promotion: Piece?, kingAttackers: Bitboard)]

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

    /// Attackers to the current player's king.
    private private(set) var attackersToKing: Bitboard

    /// The current player's king is in check.
    public var kingIsChecked: Bool {
        return attackersToKing != 0
    }

    /// The current player's king is checked by two or more pieces.
    public var kingIsDoubleChecked: Bool {
        return attackersToKing.count > 1
    }

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
    public private(set) var halfmoves: UInt

    /// The target move location for an en passant.
    public var enPassantTarget: Square? {
        guard let (move, piece, _, _, _) = _moveHistory.last, case .Pawn = piece else {
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

    /// The outcome for `self` if no moves are available.
    public var outcome: Outcome? {
        let moves = _availableMoves(considerHalfmoves: false)
        if moves.isEmpty {
            if kingIsChecked {
                return .Win(playerTurn.inverse())
            } else {
                return .Draw
            }
        } else if halfmoves >= 100 {
            return .Draw
        } else {
            return nil
        }
    }

    /// Create a game from another.
    private init(game: Game) {
        self._moveHistory    = game._moveHistory
        self._undoHistory    = game._undoHistory
        self.board           = game.board
        self.playerTurn      = game.playerTurn
        self.castlingRights  = game.castlingRights
        self.mode            = game.mode
        self.variant         = game.variant
        self.attackersToKing = game.attackersToKing
        self.halfmoves       = game.halfmoves
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
        self.attackersToKing = 0
        self.halfmoves = 0
    }

    /// Returns a copy of `self`.
    ///
    /// - Complexity: O(1).
    @warn_unused_result
    public func copy() -> Game {
        return Game(game: self)
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

    /// Returns the moves bitboard currently available for the piece at `square`, if any.
    @warn_unused_result
    private func _movesBitboardForPiece(at square: Square, considerHalfmoves: Bool) -> Bitboard {
        if considerHalfmoves && halfmoves >= 100 {
            return 0
        }
        guard let piece = board[square] where piece.color == playerTurn else {
            return 0
        }
        if kingIsDoubleChecked {
            guard piece.isKing else {
                return 0
            }
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

        let player = playerTurn
        for moveSquare in movesBitboard.squares {
            try! _execute(move: square >>> moveSquare)
            if board.attackersToKing(for: player) != 0 {
                movesBitboard[moveSquare] = false
            }
            undoMove()
        }

        return movesBitboard
    }

    /// Returns the moves currently available for the piece at `square`, if any.
    @warn_unused_result
    private func _movesForPiece(at square: Square, considerHalfmoves flag: Bool) -> [Move] {
        return _movesBitboardForPiece(at: square, considerHalfmoves: flag).moves(from: square)
    }

    /// Returns the available moves for the current player.
    @warn_unused_result
    private func _availableMoves(considerHalfmoves flag: Bool) -> [Move] {
        return Array(Square.all.map({ _movesForPiece(at: $0, considerHalfmoves: flag) }).flatten())
    }

    /// Returns the available moves for the current player.
    @warn_unused_result
    public func availableMoves() -> [Move] {
        return _availableMoves(considerHalfmoves: true)
    }

    /// Returns the moves bitboard currently available for the piece at `square`, if any.
    @warn_unused_result
    public func movesBitboardForPiece(at square: Square) -> Bitboard {
        return _movesBitboardForPiece(at: square, considerHalfmoves: true)
    }

    /// Returns the moves currently available for the piece at `square`, if any.
    @warn_unused_result
    public func movesForPiece(at square: Square) -> [Move] {
        return _movesForPiece(at: square, considerHalfmoves: true)
    }

    /// Returns the moves currently available for the piece at `location`, if any.
    @warn_unused_result
    public func movesForPiece(at location: Location) -> [Move] {
        return movesForPiece(at: Square(location: location))
    }

    /// Returns `true` if the move is legal.
    @warn_unused_result
    public func isLegal(move move: Move) -> Bool {
        let moves = movesBitboardForPiece(at: move.start)
        return Bitboard(square: move.end).intersects(with: moves)
    }

    /// Executes a move without checking the legality of the move.
    private func _execute(move move: Move, @noescape promotion: () -> Piece) throws {
        let piece = board[move.start]!
        var endPiece = piece
        var capture = board[move.end]
        var captureSquare = move.end
        if case .Pawn = piece {
            if move.end.rank == Rank(endFor: playerTurn) {
                let promotion = promotion()
                guard promotion.color == playerTurn else {
                    throw MoveExecutionError.InvalidPromotionPiece(promotion)
                }
                endPiece = promotion
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

        _moveHistory.append((move, piece, capture, attackersToKing, halfmoves))

        if let capture = capture {
            board[capture][captureSquare] = false
        }

        if capture == nil && !piece.isPawn {
            halfmoves += 1
        } else {
            halfmoves = 0
        }

        board[piece][move.start] = false
        board[endPiece][move.end] = true
        playerTurn.invert()
    }

    /// Executes a move without checking the legality of the move.
    private func _execute(move move: Move) throws {
        try _execute(move: move, promotion: { .Queen(playerTurn) })
    }

    /// Executes `move`, updating the state for `self`.
    ///
    /// - Parameter move: The move to be executed.
    /// - Parameter promotion: A closure returning a promotion piece if a pawn promotion occurs.
    ///
    /// - Throws: `MoveExecutionError` if `move` is illegal or if `promotion` is invalid.
    public func execute(move move: Move, @noescape  promotion: () -> Piece) throws {
        guard isLegal(move: move) else {
            throw MoveExecutionError.IllegalMove(move, playerTurn, board)
        }
        try _execute(move: move, promotion: promotion)
        if kingIsChecked {
            attackersToKing = 0
        } else {
            attackersToKing = board.attackersToKing(for: playerTurn)
        }
        _undoHistory = []
    }

    /// Executes `move`, updating the state for `self`.
    ///
    /// - Parameter move: The move to be executed.
    /// - Parameter promotion: A piece for a pawn promotion.
    ///
    /// - Throws: `MoveExecutionError` if `move` is illegal or if `promotion` is invalid.
    public func execute(move move: Move, promotion: Piece) throws {
        try execute(move: move, promotion: { promotion })
    }

    /// Executes `move`, updating the state for `self`.
    ///
    /// - Parameter move: The move to be executed.
    ///
    /// - Throws: `MoveExecutionError` if `move` is illegal.
    public func execute(move move: Move) throws {
        try execute(move: move, promotion: .Queen(playerTurn))
    }

    /// Returns the last move on the move stack, if any.
    @warn_unused_result
    public func moveToUndo() -> Move? {
        return _moveHistory.last?.move
    }

    /// Returns the last move on the undo stack, if any.
    @warn_unused_result
    public func moveToRedo() -> Move? {
        return _undoHistory.last?.move
    }

    /// Undoes the previous move and returns it, if any.
    public func undoMove() -> Move? {
        guard let (move, piece, capture, attackers, halfmoves) = _moveHistory.popLast() else {
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
        _undoHistory.append((move, promotion, attackers))
        if let capture = capture {
            board[capture][captureSquare] = true
        }
        if let promotion = promotion {
            board[promotion][move.end] = false
        }
        board[piece][move.end] = false
        board[piece][move.start] = true
        playerTurn.invert()
        attackersToKing = attackers
        self.halfmoves = halfmoves
        return move
    }

    /// Redoes the previous undone move and returns it, if any.
    public func redoMove() -> Move? {
        guard let (move, promotion, attackers) = _undoHistory.popLast() else {
            return nil
        }
        if let promotion = promotion {
            try! _execute(move: move, promotion: { promotion })
        } else {
            try! _execute(move: move)
        }
        attackersToKing = attackers
        return move
    }

}

/// An error in move execution.
///
/// Thrown by the `execute(move:promotion:)` method for a `Board` instance.
public enum MoveExecutionError: ErrorType {

    /// Attempted illegal move.
    case IllegalMove(Move, Color, Board)

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
