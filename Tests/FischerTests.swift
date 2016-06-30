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
        XCTAssertEqual(Board(variant: .Standard), Board())
        XCTAssertNotEqual(Board(variant: nil), Board())
    }

    func testBoardEquality() {
        XCTAssertEqual(Board(), Board())
        XCTAssertEqual(Board(variant: nil), Board(variant: nil))
        XCTAssertNotEqual(Board(), Board(variant: nil))
        var board = Board(variant: .Standard)
        board.removePiece(at: ("A", 1))
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
                if case .Pawn = piece {
                    XCTAssertTrue([2, 7].contains(rank))
                } else {
                    XCTAssertTrue([1, 8].contains(rank))
                }
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
        XCTAssertEqual(.Pawn(.White), board[("A", 2)])
        XCTAssertEqual(.King(.Black), board[("E", 8)])
        let piece = Piece.Pawn(.Black)
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
        XCTAssertEqual(File.all, [.A, .B, .C, .D, .E, .F, .G, .H])
    }

    func testAllRanks() {
        XCTAssertEqual(Rank.all, [1, 2, 3, 4, 5, 6, 7, 8])
    }

    func testFileOpposite() {
        let all = File.all
        for (a, b) in zip(all, all.reverse()) {
            XCTAssertEqual(a.opposite(), b)
        }
    }

    func testRankOpposite() {
        let all = Rank.all
        for (a, b) in zip(all, all.reverse()) {
            XCTAssertEqual(a.opposite(), b)
        }
    }

    func testFileTo() {
        XCTAssertEqual(File.A.to(.H), File.all)
        XCTAssertEqual(File.A.to(.A), [File.A])
    }

    func testRankTo() {
        XCTAssertEqual(Rank.One.to(.Eight), Rank.all)
        XCTAssertEqual(Rank.One.to(.One), [Rank.One])
    }

    func testFileBetween() {
        XCTAssertEqual(File.C.between(.F), [.D, .E])
        XCTAssertEqual(File.C.between(.D), [])
        XCTAssertEqual(File.C.between(.C), [])
    }

    func testRankBetween() {
        XCTAssertEqual(Rank.Two.between(.Five), [.Three, .Four])
        XCTAssertEqual(Rank.Two.between(.Three), [])
        XCTAssertEqual(Rank.Two.between(.Two), [])
    }

    func testFileFromCharacter() {
        func test(range: Range<Int>) {
            for u in range {
                XCTAssertNotNil(File(Character(UnicodeScalar(u))))
            }
        }
        test(65...72)
        test(97...104)
    }

    func testRankFromNumber() {
        for n in 1...8 {
            XCTAssertNotNil(Rank(n))
        }
    }

    func testMoveEquality() {
        let move = Move(start: .A1, end: .C3)
        XCTAssertEqual(move, move)
        XCTAssertEqual(move, Move(start: .A1, end: .C3))
        XCTAssertNotEqual(move, Move(start: .A1, end: .B1))
    }

    func testMoveRotation() {
        let move = Move(start: .A1, end: .C6)
        let rotated = move.rotated()
        XCTAssertTrue(rotated.start == .H8)
        XCTAssertTrue(rotated.end == .F3)
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
                guard case MoveExecutionError.IllegalMove = error else {
                    XCTFail("Expected MoveExecutionError.IllegalMove, got \(error)")
                    return
                }
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
            try game.execute(move: Move(start: .C2, end: .C4))
            try game.execute(move: Move(start: .C7, end: .C6))
            try game.execute(move: Move(start: .C4, end: .C5))
            try game.execute(move: Move(start: .D7, end: .D5))
            try game.execute(move: Move(start: .C5, end: .D6))
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
            var redoMoves = moves.reverse() as [Move]

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
