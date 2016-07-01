//
//  FischerTests.swift
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

import XCTest
@testable import Fischer

class FischerTests: XCTestCase {

    func testBoardInitializer() {
        #if swift(>=3)
            XCTAssertEqual(Board(variant: .standard), Board())
        #else
            XCTAssertEqual(Board(variant: .Standard), Board())
        #endif
        XCTAssertNotEqual(Board(variant: nil), Board())
    }

    func testBoardEquality() {
        XCTAssertEqual(Board(), Board())
        XCTAssertEqual(Board(variant: nil), Board(variant: nil))
        XCTAssertNotEqual(Board(), Board(variant: nil))
        #if swift(>=3)
            var board = Board(variant: .standard)
            board.removePiece(at: .a1)
        #else
            var board = Board(variant: .Standard)
            board.removePiece(at: .A1)
        #endif
        XCTAssertNotEqual(Board(), board)
    }

    func testBoardPopulate() {
        let board = Board()
        XCTAssertEqual(board.pieces.count, 32)
        XCTAssertEqual(board.whitePieces.count, 16)
        XCTAssertEqual(board.blackPieces.count, 16)
        for file in File.all { for rank in Rank.all {
            if let piece = board[(file, rank)] {
                let color = piece.color
                XCTAssertTrue((color.isWhite ? [1, 2] : [7, 8]).contains(rank))
                if piece.isPawn {
                    XCTAssertTrue([2, 7].contains(rank))
                } else {
                    XCTAssertTrue([1, 8].contains(rank))
                }
                #if swift(>=3)
                    switch piece {
                    case .pawn:
                        break
                    case .knight:
                        XCTAssertTrue([.b, .g].contains(file))
                    case .bishop:
                        XCTAssertTrue([.c, .f].contains(file))
                    case .rook:
                        XCTAssertTrue([.a, .h].contains(file))
                    case .queen:
                        XCTAssertEqual(file, File.d)
                    case .king:
                        XCTAssertEqual(file, File.e)
                    }
                #else
                    switch piece {
                    case .Pawn:
                        break
                    case .Knight:
                        XCTAssertTrue([.B, .G].contains(file))
                    case .Bishop:
                        XCTAssertTrue([.C, .F].contains(file))
                    case .Rook:
                        XCTAssertTrue([.A, .H].contains(file))
                    case .Queen:
                        XCTAssertEqual(file, File.D)
                    case .King:
                        XCTAssertEqual(file, File.E)
                    }
                #endif
            } else {
                XCTAssertTrue([3, 4, 5, 6].contains(rank))
            }
        } }
        XCTAssertTrue(Board(variant: nil).pieces.isEmpty)
    }

    func testBoardSequence() {
        let board = Board()
        let spaces = Array(board)
        let pieces = spaces.flatMap({ $0.piece })
        let whitePieces = pieces.filter({ $0.color.isWhite })
        let blackPieces = pieces.filter({ $0.color.isBlack })
        XCTAssertEqual(spaces.count, 64)
        XCTAssertEqual(pieces.count, 32)
        XCTAssertEqual(whitePieces.count, 16)
        XCTAssertEqual(blackPieces.count, 16)
    }

    func testBoardSubscript() {
        var board = Board()
        #if swift(>=3)
            XCTAssertEqual(.pawn(.white), board[.a2])
            XCTAssertEqual(.king(.black), board[.e8])
            let piece = Piece.pawn(.black)
        #else
            XCTAssertEqual(.Pawn(.White), board[.A2])
            XCTAssertEqual(.King(.Black), board[.E8])
            let piece = Piece.Pawn(.Black)
        #endif
        let location = ("A", 3) as Location
        XCTAssertNil(board[location])
        board[location] = piece
        XCTAssertEqual(board[location], piece)
        board[location] = nil
        XCTAssertNil(board[location])
    }

    func testBoardSwap() {
        let start = Board()
        var board = start
        let location1 = ("D", 1) as Location
        let location2 = ("F", 2) as Location
        board.swap(location1, location2)
        XCTAssertEqual(start[location1], board[location2])
        XCTAssertEqual(start[location2], board[location1])
    }

    func testAllFiles() {
        XCTAssertEqual(File.all, ["a", "b", "c", "d", "e", "f", "g", "h"])
    }

    func testAllRanks() {
        XCTAssertEqual(Rank.all, [1, 2, 3, 4, 5, 6, 7, 8])
    }

    func testFileOpposite() {
        let all = File.all
        #if swift(>=3)
            let reversed = all.reversed()
        #else
            let reversed = all.reverse()
        #endif
        for (a, b) in zip(all, reversed) {
            XCTAssertEqual(a.opposite(), b)
        }
    }

    func testRankOpposite() {
        let all = Rank.all
        #if swift(>=3)
            let reversed = all.reversed()
        #else
            let reversed = all.reverse()
        #endif
        for (a, b) in zip(all, reversed) {
            XCTAssertEqual(a.opposite(), b)
        }
    }

    func testFileTo() {
        #if swift(>=3)
            XCTAssertEqual(File.a.to(.h), File.all)
            XCTAssertEqual(File.a.to(.a), [File.a])
        #else
            XCTAssertEqual(File.A.to(.H), File.all)
            XCTAssertEqual(File.A.to(.A), [File.A])
        #endif
    }

    func testRankTo() {
        #if swift(>=3)
            XCTAssertEqual(Rank.one.to(.eight), Rank.all)
            XCTAssertEqual(Rank.one.to(.one), [Rank.one])
        #else
            XCTAssertEqual(Rank.One.to(.Eight), Rank.all)
            XCTAssertEqual(Rank.One.to(.One), [Rank.One])
        #endif
    }

    func testFileBetween() {
        #if swift(>=3)
            XCTAssertEqual(File.c.between(.f), [.d, .e])
            XCTAssertEqual(File.c.between(.d), [])
            XCTAssertEqual(File.c.between(.c), [])
        #else
            XCTAssertEqual(File.C.between(.F), [.D, .E])
            XCTAssertEqual(File.C.between(.D), [])
            XCTAssertEqual(File.C.between(.C), [])
        #endif
    }

    func testRankBetween() {
        #if swift(>=3)
            XCTAssertEqual(Rank.two.between(.five), [.three, .four])
            XCTAssertEqual(Rank.two.between(.three), [])
            XCTAssertEqual(Rank.two.between(.two), [])
        #else
            XCTAssertEqual(Rank.Two.between(.Five), [.Three, .Four])
            XCTAssertEqual(Rank.Two.between(.Three), [])
            XCTAssertEqual(Rank.Two.between(.Two), [])

        #endif
    }

    func testFileFromCharacter() {
        for u in 65...72 {
            XCTAssertNotNil(File(Character(UnicodeScalar(u))))
        }
        for u in 97...104 {
            XCTAssertNotNil(File(Character(UnicodeScalar(u))))
        }
    }

    func testRankFromNumber() {
        for n in 1...8 {
            XCTAssertNotNil(Rank(n))
        }
    }

    func testMoveEquality() {
        #if swift(>=3)
            let move = Move(start: .a1, end: .c3)
            XCTAssertEqual(move, move)
            XCTAssertEqual(move, Move(start: .a1, end: .c3))
            XCTAssertNotEqual(move, Move(start: .a1, end: .b1))
        #else
            let move = Move(start: .A1, end: .C3)
            XCTAssertEqual(move, move)
            XCTAssertEqual(move, Move(start: .A1, end: .C3))
            XCTAssertNotEqual(move, Move(start: .A1, end: .B1))
        #endif
    }

    func testMoveRotation() {
        #if swift(>=3)
            let move = Move(start: .a1, end: .c6)
            let rotated = move.rotated()
            XCTAssertEqual(rotated.start, Square.h8)
            XCTAssertEqual(rotated.end, Square.f3)
        #else
            let move = Move(start: .A1, end: .C6)
            let rotated = move.rotated()
            XCTAssertEqual(rotated.start, Square.H8)
            XCTAssertEqual(rotated.end, Square.F3)
        #endif
    }

    func testMoveOperator() {
        for file in File.all { for rank in Rank.all {
            let start = Square(file: file, rank: rank)
            let end = Square(file: file.opposite(), rank: rank.opposite())
            XCTAssertEqual(Move(start: start, end: end), start >>> end)
        } }
    }

    func testGameRandomMoves() {
        let game = Game()
        do {
            while let move = game.availableMoves().random() {
                let enemyColor = game.playerTurn.inverse()
                let enemyKingSpace = game.board.squareForKing(for: enemyColor)
                guard move.end != enemyKingSpace else {
                    XCTFail("Attempted attack to king for \(enemyColor) at \(move.end)")
                    return
                }
                try game.execute(move: move)
            }
            guard let outcome = game.outcome else {
                XCTFail("Expected outcome for complete game")
                return
            }
            if let color = outcome.winColor {
                guard game.kingIsChecked && game.board.kingIsChecked(for: color.inverse()) else {
                    XCTFail("\(color.inverse()) should be in check if \(color) wins")
                    return
                }
            }
        } catch {
            XCTFail(String(error))
        }
    }

    func testGameDoubleStep() {
        let game = Game()
        for file in File.all {
            let move = Move(start: Square(location: (file, 2)), end: Square(location: (file, 5)))
            XCTAssertThrowsError(try game.execute(move: move)) { error in
                #if swift(>=3)
                    guard case MoveExecutionError.illegalMove = error else {
                        XCTFail("Expected MoveExecutionError.IllegalMove, got \(error)")
                        return
                    }
                #else
                    guard case MoveExecutionError.IllegalMove = error else {
                        XCTFail("Expected MoveExecutionError.IllegalMove, got \(error)")
                        return
                    }
                #endif
            }
        }
        do {
            for file in File.all {
                try game.execute(move: Move(start: Square(location: (file, 2)), end: Square(location: (file, 4))))
                try game.execute(move: Move(start: Square(location: (file, 7)), end: Square(location: (file, 5))))
            }
        } catch {
            XCTFail(String(error))
        }
    }

    func testGameEnPassant() {
        let game = Game()
        do {
            #if swift(>=3)
                try game.execute(move: Move(start: .c2, end: .c4))
                try game.execute(move: Move(start: .c7, end: .c6))
                try game.execute(move: Move(start: .c4, end: .c5))
                try game.execute(move: Move(start: .d7, end: .d5))
                try game.execute(move: Move(start: .c5, end: .d6))
            #else
                try game.execute(move: Move(start: .C2, end: .C4))
                try game.execute(move: Move(start: .C7, end: .C6))
                try game.execute(move: Move(start: .C4, end: .C5))
                try game.execute(move: Move(start: .D7, end: .D5))
                try game.execute(move: Move(start: .C5, end: .D6))
            #endif
        } catch {
            XCTFail(String(error))
        }
    }

    func testGameUndoAndRedo() {
        do {
            let game = Game()
            let startBoard = game.board
            var endBoard = startBoard
            var moves = [Move]()

            while let move = game.availableMoves().random() {
                try game.execute(move: move)
                moves.append(move)
                endBoard = game.board
            }
            #if swift(>=3)
                var redoMoves = moves.reversed() as [Move]
            #else
                var redoMoves = moves.reverse() as [Move]
            #endif

            while let move = game.moveToUndo() {
                XCTAssertEqual(move, game.undoMove())
                XCTAssertEqual(move, moves.popLast())
            }
            XCTAssert(moves.isEmpty)
            XCTAssertEqual(game.board, startBoard)

            while let move = game.moveToRedo() {
                XCTAssertEqual(move, game.redoMove())
                XCTAssertEqual(move, redoMoves.popLast())
            }
            XCTAssertEqual(game.board, endBoard)
        } catch {
            XCTFail(String(error))
        }
    }

}

extension Array {

    func random() -> Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(count)))]
    }

}
