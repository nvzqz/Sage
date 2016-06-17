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

    /// Creates a new chess game.
    ///
    /// - Parameter mode: The game's mode. Default is `HumanVsHuman`.
    public init(mode: Mode = .HumanVsHuman) {
        self._moveHistory = []
        self._undoHistory = []
        self.board = Board()
        self.playerTurn = .White
        self.castlingAvailability = .Starting
        self.mode = mode
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

    /// Returns a location for an obstructing piece within the sequence.
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
        case .Rook:
            // The move is along an axis
            if let error = errorForAxialMove() {
                return .Error(error)
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
        case .King:
            if /* Castle */ abs(move.fileChange) == 2 {
                switch move.end {
                case (.C, .One):
                    guard castlingAvailability.contains(.WhiteQueenside) else {
                        return .Error(.NoAvailability(.WhiteQueenside))
                    }
                case (.G, .One):
                    guard castlingAvailability.contains(.WhiteKingside) else {
                        return .Error(.NoAvailability(.WhiteKingside))
                    }
                case (.C, .Eight):
                    guard castlingAvailability.contains(.BlackQueenside) else {
                        return .Error(.NoAvailability(.BlackQueenside))
                    }
                case (.G, .Eight):
                    guard castlingAvailability.contains(.BlackKingside) else {
                        return .Error(.NoAvailability(.BlackKingside))
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
        }
        return .Value(piece)
    }

    /// Returns `true` if the move is valid for the given color or any color if
    /// `nil`.
    ///
    /// Prefer calling `executeMove(_:)` with a try/catch when checking for
    /// errors before executing a move instead of `isValidMove(_:for:)`.
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
                execute(board.removePieceAt((move.end.file, move.start.rank)))
            } else if /* Promotion */ move.end.rank == (color.isWhite ? 8 : 1) {
                let promotion = promotion?()
                if let promotion = promotion {
                    guard promotion.canPromote(color) else {
                        throw MoveExecutionError.InvalidPromotionPiece(promotion)
                    }
                }
                board.removePieceAt(move.start)
                let capture = board[move.end]
                board[move.end] = promotion ?? .Queen(color)
                _moveHistory.append((move, piece, capture))
            } else {
                execute(board.removePieceAt(move.end))
            }
        case .King(let color):
            if color.isWhite {
                castlingAvailability.remove([.WhiteKingside, .WhiteQueenside])
            } else {
                castlingAvailability.remove([.BlackKingside, .BlackQueenside])
            }
            if /* Castle */ abs(move.fileChange) == 2 {
                let rank = move.start.rank
                let movedRight = move.end.file == .G
                let oldRookFile: File = movedRight ? .H : .A
                let newRookFile: File = movedRight ? .F : .D
                board.swap((oldRookFile, rank), (newRookFile, rank))
                execute()
            } else {
                execute(board.removePieceAt(move.end))
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
            execute(board.removePieceAt(move.end))
        default:
            execute(board.removePieceAt(move.end))
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
        board[move.start] = board.removePieceAt(move.end)
        func append() { _undoHistory.append((move, nil)) }
        switch piece {
        case .King where abs(move.fileChange) == 2:
            let (new, old) = move.isRightward ? (File.F, File.H) : (.D, .A)
            let rank = move.start.rank
            board[(old, rank)] = board.removePieceAt((new, rank))
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

    /// Attempted to castle without availability.
    case NoAvailability(CastlingAvailability)

}
