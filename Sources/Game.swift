//
//  Game.swift
//  Sage
//
//  Copyright 2016-2017 Nikolai Vazquez
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

    /// A chess game outcome.
    public enum Outcome: Hashable, CustomStringConvertible {

        /// A win for a `Color`.
        case win(Color)

        /// A draw.
        case draw

        /// Win regardless of Swift version.
        internal static func _win(_ color: Color) -> Outcome {
            return .win(color)
        }

        /// The hash value.
        public var hashValue: Int {
            return winColor?.hashValue ?? 2
        }

        /// A textual representation of `self`.
        public var description: String {
            if let color = winColor {
                return color.isWhite ? "1-0" : "0-1"
            } else {
                return "1/2-1/2"
            }
        }

        /// The color for the winning player.
        public var winColor: Color? {
            guard case let .win(color) = self else {
                return nil
            }
            return color
        }

        /// `self` is a win.
        public var isWin: Bool {
            if case .win = self {
                return true
            } else {
                return false
            }
        }

        /// `self` is a draw.
        public var isDraw: Bool {
            return !isWin
        }

        /// Create an outcome from `string`. Ignores whitespace.
        public init?(_ string: String) {
            let stripped = string.split(separator: " ").map(String.init).joined(separator: "")
            switch stripped {
            case "1-0":
                self = ._win(.white)
            case "0-1":
                self = ._win(.black)
            case "1/2-1/2":
                self = .draw
            default:
                return nil
            }
        }

        /// The point value for a player. Can be 1 for win, 0.5 for draw, or 0 for loss.
        public func value(for playerColor: Color) -> Double {
            return winColor.map({ $0 == playerColor ? 1 : 0 }) ?? 0.5
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
                    playerTurn: PlayerTurn = .white,
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

        /// Create a position from a valid FEN string.
        ///
        /// - seealso: [FEN (Wikipedia)](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation),
        ///            [FEN (Chess Programming Wiki)](https://chessprogramming.wikispaces.com/Forsyth-Edwards+Notation)
        public init?(fen: String) {
            let parts = fen.split(separator: " ").map(String.init)
            guard
                    parts.count == 6,
                    let board = Board(fen: parts[0]),
                    parts[1].count == 1,
                    let playerTurn = parts[1].first.flatMap(Color.init),
                    let rights = CastlingRights(string: parts[2]),
                    let halfmoves = UInt(parts[4]),
                    let fullmoves = UInt(parts[5]),
                    fullmoves > 0 else {
                return nil
            }
            var target: Square? = nil
            let targetStr = parts[3]
            let targetChars = targetStr
            if targetChars.count == 2 {
                guard let square = Square(targetStr) else {
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

        internal func _validationError() -> PositionError? {
            for color in Color.all {
                guard board.count(of: Piece(king: color)) == 1 else {
                    return .wrongKingCount(color)
                }
            }
            for right in castlingRights {
                let color = right.color
                let king = Piece(king: color)
                guard board.bitboard(for: king) == Bitboard(startFor: king) else {
                    return .missingKing(right)
                }
                let rook = Piece(rook: color)
                let square = Square(file: right.side.isKingside ? .h : .a,
                        rank: Rank(startFor: color))
                guard board.bitboard(for: rook)[square] else {
                    return .missingRook(right)
                }
            }
            if let target = enPassantTarget {
                guard target.rank == (playerTurn.isWhite ? 6 : 3) else {
                    return .wrongEnPassantTargetRank(target.rank)
                }
                if let piece = board[target] {
                    return .nonEmptyEnPassantTarget(target, piece)
                }
                let pawnSquare = Square(file: target.file, rank: playerTurn.isWhite ? 5 : 4)
                guard board[pawnSquare] == Piece(pawn: playerTurn.inverse()) else {
                    return .missingEnPassantPawn(pawnSquare)
                }
                let startSquare = Square(file: target.file, rank: playerTurn.isWhite ? 7 : 2)
                if let piece = board[startSquare] {
                    return .nonEmptyEnPassantSquare(startSquare, piece)
                }
            }
            return nil
        }

        /// Returns the FEN string for the position.
        ///
        /// - seealso: [FEN (Wikipedia)](https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation),
        ///            [FEN (Chess Programming Wiki)](https://chessprogramming.wikispaces.com/Forsyth-Edwards+Notation)
        public func fen() -> String {
            let transform = {
                "\($0 as Square)".lowercased()
            }
            return board.fen()
                    + " \(playerTurn.isWhite ? "w" : "b") \(castlingRights) "
                    + (enPassantTarget.map(transform) ?? "-")
                    + " \(halfmoves) \(fullmoves)"
        }

    }

    /// An error in position validation.
    public enum PositionError: Error {

        /// Found number other than 1 for king count.
        case wrongKingCount(Color)

        /// King missing for castling right.
        case missingKing(CastlingRights.Right)

        /// Rook missing for castling right.
        case missingRook(CastlingRights.Right)

        /// Wrong rank for en passant target.
        case wrongEnPassantTargetRank(Rank)

        /// Non empty en passant target square.
        case nonEmptyEnPassantTarget(Square, Piece)

        /// Pawn missing for previous en passant.
        case missingEnPassantPawn(Square)

        /// Piece found at start of en passant move.
        case nonEmptyEnPassantSquare(Square, Piece)

    }

    /// An error in move execution.
    ///
    /// Thrown by the `execute(move:promotion:)` or `execute(uncheckedMove:promotion:)` method for a `Game` instance.
    public enum ExecutionError: Error {

        /// Missing piece at a square.
        case missingPiece(Square)

        /// Attempted illegal move.
        case illegalMove(Move, Color, Board)

        /// Could not promote with a piece kind.
        case invalidPromotion(Piece.Kind)

        /// The error message.
        public var message: String {
            switch self {
            case let .missingPiece(square):
                return "Missing piece: \(square)"
            case let .illegalMove(move, color, board):
                return "Illegal move: \(move) for \(color) on \(board)"
            case let .invalidPromotion(pieceKind):
                return "Invalid promoton: \(pieceKind)"
            }
        }

    }

    /// A player turn.
    public typealias PlayerTurn = Color

    /// All of the conducted moves in the game.
    private var _moveHistory: [(move: Move,
                                piece: Piece,
                                capture: Piece?,
                                enPassantTarget: Square?,
                                kingAttackers: Bitboard,
                                halfmoves: UInt,
                                rights: CastlingRights)]

    /// All of the undone moves in the game.
    private var _undoHistory: [(move: Move, promotion: Piece.Kind?, enPassantTarget: Square?, kingAttackers: Bitboard)]

    /// The game's board.
    public private(set) var board: Board

    /// The current player's turn.
    public private(set) var playerTurn: PlayerTurn

    /// The castling rights.
    public private(set) var castlingRights: CastlingRights

    /// The white player.
    public var whitePlayer: Player

    /// The black player.
    public var blackPlayer: Player

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
    public private(set) var fullmoves: UInt

    /// The current halfmove clock.
    public private(set) var halfmoves: UInt

    /// The target move location for an en passant.
    public private(set) var enPassantTarget: Square?

    /// The captured piece for the last move.
    public var captureForLastMove: Piece? {
        return _moveHistory.last?.capture
    }

    /// The current position for `self`.
    public var position: Position {
        return Position(board: board,
                playerTurn: playerTurn,
                castlingRights: castlingRights,
                enPassantTarget: enPassantTarget,
                halfmoves: halfmoves,
                fullmoves: fullmoves)
    }

    /// The outcome for `self` if no moves are available.
    public var outcome: Outcome? {
        let moves = _availableMoves(considerHalfmoves: false)
        if moves.isEmpty {
            return kingIsChecked ? .win(playerTurn.inverse()) : .draw
        } else if halfmoves >= 100 {
            return .draw
        } else {
            return nil
        }
    }

    /// The game has no more available moves.
    public var isFinished: Bool {
        return availableMoves().isEmpty
    }

    /// Create a game from another.
    private init(game: Game) {
        self._moveHistory = game._moveHistory
        self._undoHistory = game._undoHistory
        self.board = game.board
        self.playerTurn = game.playerTurn
        self.castlingRights = game.castlingRights
        self.whitePlayer = game.whitePlayer
        self.blackPlayer = game.blackPlayer
        self.variant = game.variant
        self.attackersToKing = game.attackersToKing
        self.halfmoves = game.halfmoves
        self.fullmoves = game.fullmoves
        self.enPassantTarget = game.enPassantTarget
    }

    /// Creates a new chess game.
    ///
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter variant: The game's chess variant. Default is standard.
    public init(whitePlayer: Player = Player(),
                blackPlayer: Player = Player(),
                variant: Variant = .standard) {
        self._moveHistory = []
        self._undoHistory = []
        self.board = Board(variant: variant)
        self.playerTurn = .white
        self.castlingRights = .all
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.variant = variant
        self.attackersToKing = 0
        self.halfmoves = 0
        self.fullmoves = 1
    }

    /// Creates a chess game from a `Position`.
    ///
    /// - parameter position: The position to start off from.
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter variant: The game's chess variant. Default is standard.
    ///
    /// - throws: `PositionError` if the position is invalid.
    public init(position: Position,
                whitePlayer: Player = Player(),
                blackPlayer: Player = Player(),
                variant: Variant = .standard) throws {
        if let error = position._validationError() {
            throw error
        }
        self._moveHistory = []
        self._undoHistory = []
        self.board = position.board
        self.playerTurn = position.playerTurn
        self.castlingRights = position.castlingRights
        self.whitePlayer = whitePlayer
        self.blackPlayer = blackPlayer
        self.variant = variant
        self.enPassantTarget = position.enPassantTarget
        self.attackersToKing = position.board.attackersToKing(for: position.playerTurn)
        self.halfmoves = position.halfmoves
        self.fullmoves = position.fullmoves
    }

    /// Creates a chess game with `moves`.
    ///
    /// - parameter moves: The moves to execute.
    /// - parameter whitePlayer: The game's white player. Default is a nameless human.
    /// - parameter blackPlayer: The game's black player. Default is a nameless human.
    /// - parameter variant: The game's chess variant. Default is standard.
    ///
    /// - throws: `ExecutionError` if any move from `moves` is illegal.
    public convenience init(moves: [Move],
                            whitePlayer: Player = Player(),
                            blackPlayer: Player = Player(),
                            variant: Variant = .standard) throws {
        self.init(whitePlayer: whitePlayer, blackPlayer: blackPlayer, variant: variant)
        for move in moves {
            try execute(move: move)
        }
    }

    /// Returns a copy of `self`.
    ///
    /// - complexity: O(1).
    public func copy() -> Game {
        return Game(game: self)
    }

    /// Returns the captured pieces for a color, or for all if color is `nil`.
    public func capturedPieces(for color: Color? = nil) -> [Piece] {
        let pieces = _moveHistory.flatMap({ $0.capture })
        if let color = color {
            return pieces.filter({ $0.color == color })
        } else {
            return pieces
        }
    }

    /// Returns the moves bitboard currently available for the piece at `square`, if any.
    private func _movesBitboardForPiece(at square: Square, considerHalfmoves: Bool) -> Bitboard {
        if considerHalfmoves && halfmoves >= 100 {
            return 0
        }
        guard let piece = board[square] else {
            return 0
        }
        guard piece.color == playerTurn else {
            return 0
        }
        if kingIsDoubleChecked {
            guard piece.kind.isKing else {
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

        if piece.kind.isPawn {
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

        if piece.kind.isKing && squareBitboard == Bitboard(startFor: piece) && !kingIsChecked {
            rightLoop: for right in castlingRights {
                let emptySquares = right.emptySquares
                guard right.color == playerTurn && allBitboard & emptySquares == 0 else {
                    continue
                }
                for square in emptySquares {
                    guard board.attackers(to: square, color: piece.color.inverse()).isEmpty else {
                        continue rightLoop
                    }
                }
                movesBitboard |= Bitboard(square: right.castleSquare)
            }
        }

        let player = playerTurn
        for moveSquare in movesBitboard {
            try! _execute(uncheckedMove: square >>> moveSquare, promotion: { .queen })
            if board.attackersToKing(for: player) != 0 {
                movesBitboard[moveSquare] = false
            }
            undoMove()
            _undoHistory.removeLast()
        }

        return movesBitboard
    }

    /// Returns the moves currently available for the piece at `square`, if any.
    private func _movesForPiece(at square: Square, considerHalfmoves flag: Bool) -> [Move] {
        return _movesBitboardForPiece(at: square, considerHalfmoves: flag).moves(from: square)
    }

    /// Returns the available moves for the current player.
    private func _availableMoves(considerHalfmoves flag: Bool) -> [Move] {
        let moves = Square.all.map({ _movesForPiece(at: $0, considerHalfmoves: flag) })
        return Array(moves.joined())
    }

    /// Returns the available moves for the current player.
    public func availableMoves() -> [Move] {
        return _availableMoves(considerHalfmoves: true)
    }

    /// Returns the moves bitboard currently available for the piece at `square`.
    public func movesBitboardForPiece(at square: Square) -> Bitboard {
        return _movesBitboardForPiece(at: square, considerHalfmoves: true)
    }

    /// Returns the moves bitboard currently available for the piece at `location`.
    public func movesBitboardForPiece(at location: Location) -> Bitboard {
        return movesBitboardForPiece(at: Square(location: location))
    }

    /// Returns the moves currently available for the piece at `square`.
    public func movesForPiece(at square: Square) -> [Move] {
        return _movesForPiece(at: square, considerHalfmoves: true)
    }

    /// Returns the moves currently available for the piece at `location`.
    public func movesForPiece(at location: Location) -> [Move] {
        return movesForPiece(at: Square(location: location))
    }

    /// Returns `true` if the move is legal.
    public func isLegal(move: Move) -> Bool {
        let moves = movesBitboardForPiece(at: move.start)
        return Bitboard(square: move.end).intersects(moves)
    }

    @inline(__always)
    private func _execute(uncheckedMove move: Move, promotion: () -> Piece.Kind) throws {
        guard let piece = board[move.start] else {
            throw ExecutionError.missingPiece(move.start)
        }
        var endPiece = piece
        var capture = board[move.end]
        var captureSquare = move.end
        let rights = castlingRights
        if piece.kind.isPawn {
            if move.end.rank == Rank(endFor: playerTurn) {
                let promotion = promotion()
                guard promotion.canPromote() else {
                    throw ExecutionError.invalidPromotion(promotion)
                }
                endPiece = Piece(kind: promotion, color: playerTurn)
            } else if move.end == enPassantTarget {
                capture = Piece(pawn: playerTurn.inverse())
                captureSquare = Square(file: move.end.file, rank: move.start.rank)
            }
        } else if piece.kind.isRook {
            switch move.start {
            case .a1: castlingRights.remove(.whiteQueenside)
            case .h1: castlingRights.remove(.whiteKingside)
            case .a8: castlingRights.remove(.blackQueenside)
            case .h8: castlingRights.remove(.blackKingside)
            default:
                break
            }
        } else if piece.kind.isKing {
            for option in castlingRights where option.color == playerTurn {
                castlingRights.remove(option)
            }
            if move.isCastle(for: playerTurn) {
                let (old, new) = move._castleSquares()
                let rook = Piece(rook: playerTurn)
                board[rook][old] = false
                board[rook][new] = true
            }
        }
        if let capture = capture, capture.kind.isRook {
            switch move.end {
            case .a1 where playerTurn.isBlack: castlingRights.remove(.whiteQueenside)
            case .h1 where playerTurn.isBlack: castlingRights.remove(.whiteKingside)
            case .a8 where playerTurn.isWhite: castlingRights.remove(.blackQueenside)
            case .h8 where playerTurn.isWhite: castlingRights.remove(.blackKingside)
            default:
                break
            }
        }

        _moveHistory.append((move, piece, capture, enPassantTarget, attackersToKing, halfmoves, rights))
        if let capture = capture {
            board[capture][captureSquare] = false
        }
        if capture == nil && !piece.kind.isPawn {
            halfmoves += 1
        } else {
            halfmoves = 0
        }
        board[piece][move.start] = false
        board[endPiece][move.end] = true
        playerTurn.invert()
    }

    /// Executes `move` without checking its legality, updating the state for `self`.
    ///
    /// - warning: Can cause unwanted effects. Should only be used with moves that are known to be legal.
    ///
    /// - parameter move: The move to be executed.
    /// - parameter promotion: A closure returning a promotion piece kind if a pawn promotion occurs.
    ///
    /// - throws: `ExecutionError` if no piece exists at `move.start` or if `promotion` is invalid.
    public func execute(uncheckedMove move: Move, promotion: () -> Piece.Kind) throws {
        try _execute(uncheckedMove: move, promotion: promotion)
        let piece = board[move.end]!
        if piece.kind.isPawn && abs(move.rankChange) == 2 {
            enPassantTarget = Square(file: move.start.file, rank: piece.color.isWhite ? 3 : 6)
        } else {
            enPassantTarget = nil
        }
        attackersToKing = board.attackersToKing(for: playerTurn)
        fullmoves = 1 + (UInt(moveCount) / 2)
        _undoHistory = []
    }

    /// Executes `move` without checking its legality, updating the state for `self`.
    ///
    /// - warning: Can cause unwanted effects. Should only be used with moves that are known to be legal.
    ///
    /// - parameter move: The move to be executed.
    /// - parameter promotion: A piece kind for a pawn promotion.
    ///
    /// - throws: `ExecutionError` if no piece exists at `move.start` or if `promotion` is invalid.
    public func execute(uncheckedMove move: Move, promotion: Piece.Kind) throws {
        try execute(uncheckedMove: move, promotion: { promotion })
    }

    /// Executes `move` without checking its legality, updating the state for `self`.
    ///
    /// - warning: Can cause unwanted effects. Should only be used with moves that are known to be legal.
    ///
    /// - parameter move: The move to be executed.
    ///
    /// - throws: `ExecutionError` if no piece exists at `move.start`.
    public func execute(uncheckedMove move: Move) throws {
        try execute(uncheckedMove: move, promotion: .queen)
    }

    /// Executes `move`, updating the state for `self`.
    ///
    /// - parameter move: The move to be executed.
    /// - parameter promotion: A closure returning a promotion piece kind if a pawn promotion occurs.
    ///
    /// - throws: `ExecutionError` if `move` is illegal or if `promotion` is invalid.
    public func execute(move: Move, promotion: () -> Piece.Kind) throws {
        guard isLegal(move: move) else {
            throw ExecutionError.illegalMove(move, playerTurn, board)
        }
        try execute(uncheckedMove: move, promotion: promotion)
    }

    /// Executes `move`, updating the state for `self`.
    ///
    /// - parameter move: The move to be executed.
    /// - parameter promotion: A piece kind for a pawn promotion.
    ///
    /// - throws: `ExecutionError` if `move` is illegal or if `promotion` is invalid.
    public func execute(move: Move, promotion: Piece.Kind) throws {
        try execute(move: move, promotion: { promotion })
    }

    /// Executes `move`, updating the state for `self`.
    ///
    /// - parameter move: The move to be executed.
    ///
    /// - throws: `ExecutionError` if `move` is illegal.
    public func execute(move: Move) throws {
        try execute(move: move, promotion: .queen)
    }

    /// Returns the last move on the move stack, if any.
    public func moveToUndo() -> Move? {
        return _moveHistory.last?.move
    }

    /// Returns the last move on the undo stack, if any.
    public func moveToRedo() -> Move? {
        return _undoHistory.last?.move
    }

    /// Undoes the previous move and returns it, if any.
    private func _undoMove() -> Move? {
        guard let (move, piece, capture, enPassantTarget, attackers, halfmoves, rights) = _moveHistory.popLast() else {
            return nil
        }
        var captureSquare = move.end
        var promotionKind: Piece.Kind? = nil
        if piece.kind.isPawn {
            if move.end == enPassantTarget {
                captureSquare = Square(file: move.end.file, rank: move.start.rank)
            } else if move.end.rank == Rank(endFor: playerTurn.inverse()), let promotion = board[move.end] {
                promotionKind = promotion.kind
                board[promotion][move.end] = false
            }
        } else if piece.kind.isKing && abs(move.fileChange) == 2 {
            let (old, new) = move._castleSquares()
            let rook = Piece(rook: playerTurn.inverse())
            board[rook][old] = true
            board[rook][new] = false
        }
        if let capture = capture {
            board[capture][captureSquare] = true
        }
        _undoHistory.append((move, promotionKind, self.enPassantTarget, self.attackersToKing))
        board[piece][move.end] = false
        board[piece][move.start] = true
        playerTurn.invert()
        self.enPassantTarget = enPassantTarget
        self.attackersToKing = attackers
        self.fullmoves = 1 + (UInt(moveCount) / 2)
        self.halfmoves = halfmoves
        self.castlingRights = rights
        return move
    }

    /// Redoes the previous undone move and returns it, if any.
    private func _redoMove() -> Move? {
        guard let (move, promotion, enPassant, attackers) = _undoHistory.popLast() else {
            return nil
        }
        try! _execute(uncheckedMove: move, promotion: { promotion ?? .queen })
        attackersToKing = attackers
        enPassantTarget = enPassant
        return move
    }

    /// Undoes the previous move and returns it, if any.
    @discardableResult
    public func undoMove() -> Move? {
        return _undoMove()
    }

    /// Redoes the previous undone move and returns it, if any.
    @discardableResult
    public func redoMove() -> Move? {
        return _redoMove()
    }
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
            && lhs.enPassantTarget == rhs.enPassantTarget
            && lhs.board == rhs.board
}
