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
    public enum Outcome: Hashable {

        /// A win for a `Color`.
        case Win(Color)

        /// A draw.
        case Draw

        /// The hash value.
        public var hashValue: Int {
            return winColor?.hashValue ?? 2
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

        /// The castling availability.
        public var castlingAvailability: CastlingAvailability

        /// The en passant target location.
        public var enPassantTarget: Location?

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
                    castlingAvailability: CastlingAvailability = .all,
                    enPassantTarget: Location? = nil,
                    halfmoves: UInt = 0,
                    fullmoves: UInt = 1) {
            self.board = board
            self.playerTurn = playerTurn
            self.castlingAvailability = castlingAvailability
            self.enPassantTarget = enPassantTarget
            self.halfmoves = halfmoves
            self.fullmoves = fullmoves
        }

        /// Create a position for a game.
        public init(game: Game) {
            self.board = game.board
            self.playerTurn = game.playerTurn
            self.castlingAvailability = game.castlingAvailability
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
                let availability = CastlingAvailability(string: parts[2]),
                let halfmoves = UInt(parts[4]),
                let fullmoves = UInt(parts[5]) where fullmoves > 0
                else { return nil }
            var target: Location? = nil
            let targetStr = parts[3]
            let targetChars = targetStr.characters
            if targetChars.count == 2 {
                guard let file = targetChars.first.flatMap(File.init),
                    let rank = targetChars.last.flatMap({ char in
                        return Int(String(char)).flatMap(Rank.init(_:))
                    }) else {
                        return nil
                }
                target = (file, rank)
            } else {
                guard targetStr == "-" else {
                    return nil
                }
            }
            self.init(board: board,
                      playerTurn: playerTurn,
                      castlingAvailability: availability,
                      enPassantTarget: target,
                      halfmoves: halfmoves,
                      fullmoves: fullmoves)
        }

        /// Returns the FEN string for the position.
        @warn_unused_result
        public func fen() -> String {
            return board.fen()
                + " \(playerTurn.isWhite ? "w" : "b") \(castlingAvailability) "
                + (enPassantTarget.map({ f, r in "\(f)\(r)".lowercaseString }) ?? "-")
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

    /// The castling availability.
    public private(set) var castlingAvailability: CastlingAvailability

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
    public var enPassantTarget: Location? {
        guard let (move, piece, _) = _moveHistory.last, case .Pawn = piece
            where abs(move.rankChange) == 2 else { return nil }
        return (move.start.file, move.isUpward ? .Three : .Six)
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
        self.castlingAvailability = .all
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

    /// The available moves for the current player.
    @warn_unused_result
    public func availableMoves() -> [Move] {
        return Array(board.map({ movesForPiece(at: $0.location) }).flatten())
    }

    /// Returns the moves currently available for the piece at `location`, if any.
    @warn_unused_result
    public func movesForPiece(at location: Location) -> [Move] {
        guard let piece = board[location] else { return [] }
        let pieceColor = piece.color
        guard pieceColor == playerTurn else { return [] }
        let (file, rank) = location
        func movesFor(locations: [Zip2Sequence<[File], [Rank]>]) -> [Move] {
            func process(locations: [(File, Rank)]) -> [Location] {
                var result: [Location] = []
                for location in locations {
                    if let color = board[location]?.color {
                        if color != playerTurn {
                            result.append(location)
                        }
                        break
                    } else {
                        result.append(location)
                    }
                }
                return result
            }
            return locations.map({ $0.filter({ $0 != location }) })
                .map(process)
                .flatten()
                .map({ location >>> $0 })
        }
        func axialMoves() -> [Move] {
            let ranks = Array(count: 8, repeatedValue: rank)
            let files = Array(count: 8, repeatedValue: file)
            let locations = [zip(file.to(.H), ranks),
                             zip(file.to(.A), ranks),
                             zip(files, rank.to(.Eight)),
                             zip(files, rank.to(.One))]
            return movesFor(locations)
        }
        func diagonalMoves() -> [Move] {
            let locations = [zip(file.to(.H), rank.to(.Eight)),
                             zip(file.to(.A), rank.to(.Eight)),
                             zip(file.to(.H), rank.to(.One)),
                             zip(file.to(.A), rank.to(.One))]
            return movesFor(locations)
        }
        func locations(from changes: [(Int, Int)]) -> [Location] {
            return changes.flatMap { fc, rc in
                file.advanced(by: fc).flatMap { newFile in
                    rank.advanced(by: rc, for: pieceColor).flatMap { newRank in
                        (newFile, newRank)
                    }
                }
            }
        }
        func moves(from changes: [(Int, Int)]) -> [Move] {
            return locations(from: changes).map({ location >>> $0 })
        }
        switch piece {
        case .Pawn:
            let changes = [(0, 1), (0, 2), (1, 1), (-1, 1)]
            return moves(from: changes).filter { move in
                if move.fileChange != 0 {
                    if let capture = board[move.end] {
                        return capture.color != pieceColor
                    } else {
                        guard let target = enPassantTarget else {
                            return false
                        }
                        return move.end == target
                    }
                } else {
                    guard board[move.end] == nil else {
                        return false
                    }
                    if abs(move.rankChange) == 2 {
                        let startRank: Rank = pieceColor.isWhite ? .Two : .Seven
                        guard move.start.rank == startRank else {
                            return false
                        }
                        let midRank = move.start.rank.advanced(by: 1, for: pieceColor)!
                        guard board[(move.start.file, midRank)] == nil else {
                            return false
                        }
                    }
                    return true
                }
            }
        case .Knight:
            let values: [(Int, Int)] = zip([1, 2], [2, 1]).reduce([]) {
                let (fc, rc) = $1
                return $0 + [(file.rawValue + fc, rank.rawValue + rc),
                             (file.rawValue - fc, rank.rawValue + rc),
                             (file.rawValue + fc, rank.rawValue - rc),
                             (file.rawValue - fc, rank.rawValue - rc)]
            }
            return values.flatMap { fileValue, rankValue in
                File(rawValue: fileValue).flatMap { newFile in
                    Rank(rawValue: rankValue).flatMap { newRank in
                        board[(newFile, newRank)]?.color != pieceColor
                            ? Move(start: location, end: (newFile, newRank))
                            : nil
                    }
                }
            }
        case .Bishop:
            return diagonalMoves()
        case .Rook:
            return axialMoves()
        case .Queen:
            return axialMoves() + diagonalMoves()
        case .King:
            let changes: [(Int, Int)] = [-1, 1].reduce([(2, 0), (-2, 0)]) {
                return $0 + [($1, $1), ($1, -$1), ($1, 0), (0, $1)]
            }
            return moves(from: changes).filter { isValidMove($0) }
        }
    }

    /// Returns a location for an obstructing piece within the sequence.
    @warn_unused_result
    private func _locationForObstruction<S: SequenceType where S.Generator.Element == Location>(s: S) -> Location? {
        for location in s {
            guard board[location] == nil else {
                return location
            }
        }
        return nil
    }

    /// Checks if the move is valid and returns the piece being moved on success
    /// or an error result on failure.
    @inline(never)
    private func _resultOf(move: Move, for color: Color? = nil) -> _MoveResult {
        // Piece exists on the board
        guard let piece = board[move.start] else {
            return .Error(.NoPieceToMove(move.start))
        }
        let pieceColor = piece.color
        // The piece's color matches the color parameter
        if let color = color {
            guard pieceColor == color else {
                return .Error(.WrongPieceColor(pieceColor))
            }
        }
        let captureColor = board[move.end]?.color
        // The capture color, if any, is not the piece's color
        guard captureColor != pieceColor else {
            return .Error(.SameColorCapturePiece)
        }
        // The piece actually moves
        guard move.isChange else {
            return .Error(.NoMovement)
        }
        // Returns the error for a diagonal move, if any
        func errorForDiagonalMove() -> MoveExecutionError? {
            guard move.isDiagonal else {
                return .WrongMovementKind(piece)
            }
            let files = move.start.file.between(move.end.file)
            let ranks = move.start.rank.between(move.end.rank)
            if let location = _locationForObstruction(zip(files, ranks)) {
                return .ObstructingPiece(location)
            }
            return nil
        }
        // Returns the error for an axial move, if any
        func errorForAxialMove() -> MoveExecutionError? {
            if move.isHorizontal {
                let files = move.start.file.between(move.end.file)
                let ranks = Repeat(count: files.count, repeatedValue: move.start.rank)
                if let location = _locationForObstruction(zip(files, ranks)) {
                    return .ObstructingPiece(location)
                }
            } else if move.isVertical {
                let ranks = move.start.rank.between(move.end.rank)
                let files = Repeat(count: ranks.count, repeatedValue: move.start.file)
                if let location = _locationForObstruction(zip(files, ranks)) {
                    return .ObstructingPiece(location)
                }
            } else {
                return .WrongMovementKind(piece)
            }
            return nil
        }
        // Check validity on per-piece basis
        switch piece {
        case .Pawn:
            // The piece is moving in the correct direction
            guard pieceColor.isWhite ? move.isUpward : move.isDownward else {
                return .Error(.WrongMovementKind(piece))
            }
            let distance = abs(move.rankChange)
            if move.isVertical {
                if /* Double step */ distance == 2 {
                    // Move starts at proper double step location
                    guard move.start.rank == (pieceColor.isWhite ? .Two : .Seven) else {
                        return .Error(.WrongMovementKind(piece))
                    }
                } else {
                    // Move is single step
                    guard distance == 1 else {
                        return .Error(.WrongMovementKind(piece))
                    }
                }
                // The space at the move end is empty (no capture)
                guard captureColor == nil else {
                    return .Error(.ObstructingPiece(move.end))
                }
            } else if /* Capture */ move.isDiagonal {
                // Only one unit of movement
                guard distance == 1 else {
                    return .Error(.WrongMovementKind(piece))
                }
                if /* En passant */ captureColor == nil {
                    // The move starts at the appropiate rank
                    guard move.start.rank == (pieceColor.isWhite ? .Five : .Four) else {
                        return .Error(.WrongMovementKind(piece))
                    }
                    // The previous move was a double step
                    guard let previousMove = _moveHistory.last,
                        case .Pawn = previousMove.piece
                        where abs(previousMove.move.rankChange) == 2 else {
                            return .Error(.NoPreviousDoubleStep)
                    }
                    // A piece exists adjacent to the end location
                    guard let capturePiece = board[(move.end.file, move.start.rank)] else {
                        return .Error(.WrongMovementKind(piece))
                    }
                    // The capture piece's color is not the moving piece's color
                    guard capturePiece.color != pieceColor else {
                        return .Error(.SameColorCapturePiece)
                    }
                }
            } else {
                return .Error(.WrongMovementKind(piece))
            }
        case .Knight:
            // The move is a valid knight jump
            guard move.isKnightJump else {
                return .Error(.WrongMovementKind(piece))
            }
        case .Bishop:
            // The move is diagonal
            if let error = errorForDiagonalMove() {
                return .Error(error)
            }
        case .Rook:
            // The move is along an axis
            if let error = errorForAxialMove() {
                return .Error(error)
            }
        case .Queen:
            // The move is along an axis or diagonal
            if move.isAxial {
                if let error = errorForAxialMove() {
                    return .Error(error)
                }
            } else if move.isDiagonal {
                if let error = errorForDiagonalMove() {
                    return .Error(error)
                }
            } else {
                return .Error(.WrongMovementKind(piece))
            }
        case .King:
            guard board[move.end] == nil else {
                return .Error(.ObstructingPiece(move.end))
            }
            if /* Castle */ abs(move.fileChange) == 2 {
                switch move.end {
                case (.C, .One):
                    guard castlingAvailability.contains(.WhiteQueenside) else {
                        return .Error(.NoAvailabilityOption(.WhiteQueenside))
                    }
                case (.G, .One):
                    guard castlingAvailability.contains(.WhiteKingside) else {
                        return .Error(.NoAvailabilityOption(.WhiteKingside))
                    }
                case (.C, .Eight):
                    guard castlingAvailability.contains(.BlackQueenside) else {
                        return .Error(.NoAvailabilityOption(.BlackQueenside))
                    }
                case (.G, .Eight):
                    guard castlingAvailability.contains(.BlackKingside) else {
                        return .Error(.NoAvailabilityOption(.BlackKingside))
                    }
                default:
                    return .Error(.WrongMovementKind(piece))
                }
                // The area between the king and rook is empty
                let rookFile: File = move.isRightward ? .G : .A
                for file in move.start.file.between(rookFile) {
                    let location = (file, move.start.rank)
                    guard board[location] == nil else {
                        return .Error(.ObstructingPiece(location))
                    }
                }
            } else {
                // The king moved 1 unit in any direction
                guard abs(move.fileChange) < 2 && abs(move.rankChange) < 2 else {
                    return .Error(.WrongMovementKind(piece))
                }
            }
        }
        return .Value(piece)
    }

    /// Returns `true` if the move is valid for the given color or any color if
    /// `nil`.
    ///
    /// Prefer calling `executeMove(_:)` with a try/catch when checking for
    /// errors before executing a move instead of `isValidMove(_:for:)`.
    @warn_unused_result
    public func isValidMove(move: Move, for color: Color? = nil) -> Bool {
        if case .Value = _resultOf(move, for: color) {
            return true
        } else {
            return false
        }
    }

    /// Executes a move without checking the validity of the move.
    @inline(never)
    private func _executeMove(move: Move, piece: Piece, promotion: (() -> Piece)?) throws {
        func execute(capture: Piece? = nil) {
            board.swap(move.start, move.end)
            _moveHistory.append((move, piece, capture))
        }
        switch piece {
        case .Pawn(let color):
            if /* En passant */ move.isDiagonal && board[move.end] == nil {
                execute(board.removePiece(at: (move.end.file, move.start.rank)))
            } else if /* Promotion */ move.end.rank == (color.isWhite ? 8 : 1) {
                let promotion = promotion?()
                if let promotion = promotion {
                    guard promotion.canPromote(color) else {
                        throw MoveExecutionError.InvalidPromotionPiece(promotion)
                    }
                }
                board.removePiece(at: move.start)
                let capture = board[move.end]
                board[move.end] = promotion ?? .Queen(color)
                _moveHistory.append((move, piece, capture))
            } else {
                execute(board.removePiece(at: move.end))
            }
        case .King(let color):
            if color.isWhite {
                castlingAvailability.remove(.WhiteKingside)
                castlingAvailability.remove(.WhiteQueenside)
            } else {
                castlingAvailability.remove(.BlackKingside)
                castlingAvailability.remove(.BlackQueenside)
            }
            if /* Castle */ abs(move.fileChange) == 2 {
                let rank = move.start.rank
                let movedRight = move.end.file == .G
                let oldRookFile: File = movedRight ? .H : .A
                let newRookFile: File = movedRight ? .F : .D
                board.swap((oldRookFile, rank), (newRookFile, rank))
                execute()
            } else {
                execute(board.removePiece(at: move.end))
            }
        case .Rook:
            switch move.start {
            case (.A, .One):
                castlingAvailability.remove(.WhiteQueenside)
            case (.H, .One):
                castlingAvailability.remove(.WhiteKingside)
            case (.A, .Eight):
                castlingAvailability.remove(.BlackKingside)
            case (.H, .Eight):
                castlingAvailability.remove(.BlackQueenside)
            default:
                break
            }
            execute(board.removePiece(at: move.end))
        default:
            execute(board.removePiece(at: move.end))
        }
        playerTurn.invert()
    }

    /// Executes the move or throws on error.
    public func executeMove(move: Move, promotion: (() -> Piece)? =  nil) throws {
        let result = _resultOf(move, for: playerTurn)
        guard case let .Value(piece) = result else {
            throw result.error!
        }
        try _executeMove(move, piece: piece, promotion: promotion)
    }

    /// Executes the move or throws on error.
    public func executeMove(move: Move, promotion: Piece) throws {
        try executeMove(move, promotion: { promotion })
    }

    /// Undoes the previous move and returns it, if any.
    public func undoMove() -> Move? {
        guard let (move, piece, _) = _moveHistory.popLast() else {
            return nil
        }
        board[move.start] = board.removePiece(at: move.end)
        func append() { _undoHistory.append((move, nil)) }
        switch piece {
        case .King where abs(move.fileChange) == 2:
            let (new, old) = move.isRightward ? (File.F, File.H) : (.D, .A)
            let rank = move.start.rank
            board[(old, rank)] = board.removePiece(at: (new, rank))
            append()
        case .Pawn where abs(move.fileChange) == 1:
            guard let previous = _moveHistory.last else { break }
            if case .Pawn = previous.piece where abs(previous.move.rankChange) == 2 {
                board[previous.move.end] = previous.piece
            }
            append()
        default:
            guard _moveHistory.count > 1 else { break }
            let other = _moveHistory[_moveHistory.endIndex - 2]
            let dest: Rank = move.isUpward ? .Eight : .One
            if case .Pawn = other.piece where move.end.rank == dest {
                _undoHistory.append((move, piece))
            } else {
                append()
            }
        }
        playerTurn.invert()
        return move
    }

    /// Redoes the previous undone move and returns it, if any.
    public func redoMove() -> Move? {
        guard let (move, promotion) = _undoHistory.popLast() else {
            return nil
        }
        let piece = board[move.start]!
        try! _executeMove(move, piece: piece, promotion: promotion.map { p in { p } })
        return move
    }

}

private typealias _MoveResult = _Result<Piece, MoveExecutionError>

/// An error in move execution.
public enum MoveExecutionError: ErrorType {

    /// The previous move to an attempted en passant was not a double step.
    case NoPreviousDoubleStep

    /// No piece found at location.
    case NoPieceToMove(Location)

    /// The move's start and end are the same.
    case NoMovement

    /// The piece being captured is the same color as that being moved.
    case SameColorCapturePiece

    /// A piece is obstructing a traversal.
    case ObstructingPiece(Location)

    /// Could not promote with a piece.
    case InvalidPromotionPiece(Piece)

    /// Moving a piece of a different color than the player turn.
    case WrongPieceColor(Color)

    /// Attempt wrong kind of move for piece.
    case WrongMovementKind(Piece)

    /// Attempted to castle without availability option.
    case NoAvailabilityOption(CastlingAvailability.Option)

}

/// Returns `true` if the outcomes are the same.
public func == (lhs: Game.Outcome, rhs: Game.Outcome) -> Bool {
    return lhs.winColor == rhs.winColor
}

/// Returns `true` if the positions are the same.
public func == (lhs: Game.Position, rhs: Game.Position) -> Bool {
    return lhs.playerTurn == rhs.playerTurn
        && lhs.castlingAvailability == rhs.castlingAvailability
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
