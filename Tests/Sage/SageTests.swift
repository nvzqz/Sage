//
//  SageTests.swift
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

import XCTest
import Foundation
@testable import Sage

class SageTests: XCTestCase {

    static let allTests = [("testBoardInitializer", testBoardInitializer),
                           ("testBoardEquality", testBoardEquality),
                           ("testBoardPopulate", testBoardPopulate),
                           ("testBoardFromCharacters", testBoardFromCharacters),
                           ("testBoardSequence", testBoardSequence),
                           ("testBoardSubscript", testBoardSubscript),
                           ("testBoardSwap", testBoardSwap),
                           ("testAllFiles", testAllFiles),
                           ("testAllRanks", testAllRanks),
                           ("testFileOpposite", testFileOpposite),
                           ("testRankOpposite", testRankOpposite),
                           ("testFileTo", testFileTo),
                           ("testRankTo", testRankTo),
                           ("testFileBetween", testFileBetween),
                           ("testRankBetween", testRankBetween),
                           ("testFileFromCharacter", testFileFromCharacter),
                           ("testRankFromNumber", testRankFromNumber),
                           ("testMoveEquality", testMoveEquality),
                           ("testMoveRotation", testMoveRotation),
                           ("testMoveOperator", testMoveOperator),
                           ("testGameRandomMoves", testGameRandomMoves),
                           ("testGameFromMoves", testGameFromMoves),
                           ("testGameDoubleStep", testGameDoubleStep),
                           ("testGameEnPassant", testGameEnPassant),
                           ("testGameUndoAndRedo", testGameUndoAndRedo),
                           ("testPGNParsingAndExporting", testPGNParsingAndExporting)]

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
                if piece.kind.isPawn {
                    XCTAssertTrue([2, 7].contains(rank))
                } else {
                    XCTAssertTrue([1, 8].contains(rank))
                }
                #if swift(>=3)
                    switch piece.kind {
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
                    switch piece.kind {
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

    func testBoardFromCharacters() {
        let board = Board(pieces: [["r", "n", "b", "q", "k", "b", "n", "r"],
                                   ["p", "p", "p", "p", "p", "p", "p", "p"],
                                   [" ", " ", " ", " ", " ", " ", " ", " "],
                                   [" ", " ", " ", " ", " ", " ", " ", " "],
                                   [" ", " ", " ", " ", " ", " ", " ", " "],
                                   [" ", " ", " ", " ", " ", " ", " ", " "],
                                   ["P", "P", "P", "P", "P", "P", "P", "P"],
                                   ["R", "N", "B", "Q", "K", "B", "N", "R"]])
        XCTAssertEqual(board, Board())
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
            XCTAssertEqual(Piece(pawn: .white), board[.a2])
            XCTAssertEqual(Piece(king: .black), board[.e8])
            let piece = Piece(pawn: .black)
        #else
            XCTAssertEqual(Piece(pawn: .White), board[.A2])
            XCTAssertEqual(Piece(king: .Black), board[.E8])
            let piece = Piece(pawn: .Black)
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

    func testGameRandomMoves() throws {
        let game = Game()
        while let move = game.availableMoves().random() {
            let enemyColor = game.playerTurn.inverse()
            let enemyKingSpace = game.board.squareForKing(for: enemyColor)
            guard move.end != enemyKingSpace else {
                let error = "Attempted attack to king for \(enemyColor): \(move.formatted())"
                    + "\nPosition: " + game.position.fen().debugDescription
                    + "\nMoves: \(game.playedMoves.formatted())"
                XCTFail(error)
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
    }

    func testGameFromMoves() throws {
        let game = Game()
        while let move = game.availableMoves().random() {
            try game.execute(uncheckedMove: move)
        }
        do {
            let moves = game.playedMoves
            let other = try Game(moves: moves)
            XCTAssertEqual(other.board, game.board)
            XCTAssertEqual(other.playedMoves, moves)
        } catch {
            XCTFail(String(error))
        }
    }

    func testGameDoubleStep() throws {
        let game = Game()
        for file in File.all {
            let move = Move(start: Square(location: (file, 2)), end: Square(location: (file, 5)))
            XCTAssertThrowsError(try game.execute(move: move)) { error in
                #if swift(>=3)
                    guard case Game.ExecutionError.illegalMove = error else {
                        XCTFail("Expected MoveExecutionError.IllegalMove, got \(error)")
                        return
                    }
                #else
                    guard case Game.ExecutionError.IllegalMove = error else {
                        XCTFail("Expected MoveExecutionError.IllegalMove, got \(error)")
                        return
                    }
                #endif
            }
        }
        for file in File.all {
            try game.execute(move: Move(start: Square(location: (file, 2)), end: Square(location: (file, 4))))
            try game.execute(move: Move(start: Square(location: (file, 7)), end: Square(location: (file, 5))))
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

    func testGameUndoAndRedo() throws {
        let game = Game()
        let startBoard = game.board
        var endBoard = startBoard
        var moves = [Move]()

        while let move = game.availableMoves().random() {
            try game.execute(uncheckedMove: move)
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
    }

    func testPGNParsingAndExporting() throws {
        let immortalGame = String()
            + "[Event \"London\"]\n"
            + "[Site \"London\"]\n"
            + "[Date \"1851.??.??\"]\n"
            + "[EventDate \"?\"]\n"
            + "[Round \"?\"]\n"
            + "[Result \"1-0\"]\n"
            + "[White \"Adolf Anderssen\"]\n"
            + "[Black \"Kieseritzky\"]\n"
            + "[ECO \"C33\"]\n"
            + "[WhiteElo \"?\"]\n"
            + "[BlackElo \"?\"]\n"
            + "[PlyCount \"45\"]\n"
            + "\n"
            + "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6 7.d3 Nh5 8.Nh4 Qg5\n"
            + "9.Nf5 c6 10.g4 Nf6 11.Rg1 cxb5 12.h4 Qg6 13.h5 Qg5 14.Qf3 Ng8 15.Bxf4 Qf6\n"
            + "16.Nc3 Bc5 17.Nd5 Qxb2 18.Bd6 Bxg1 19. e5 Qxa1+ 20. Ke2 Na6 21.Nxg7+ Kd8\n"
            + "22.Qf6+ Nxf6 23.Be7# 1-0\n"

        let returnGame = String()
            + "[Event \"F/S Return Match\"]\n"
            + "[Site \"Belgrade, Serbia Yugoslavia|JUG\"]\n"
            + "[Date \"1992.11.04\"]\n"
            + "[Round \"29\"]\n"
            + "[White \"Fischer, Robert J.\"]\n"
            + "[Black \"Spassky, Boris V.\"]\n"
            + "[Result \"1/2-1/2\"]\n"
            + "\n"
            + "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 {This opening is called the Ruy Lopez.}\n"
            + "4. Ba4 Nf6 5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8  10. d4 Nbd7\n"
            + "11. c4 c6 12. cxb5 axb5 13. Nc3 Bb7 14. Bg5 b4 15. Nb1 h6 16. Bh4 c5 17. dxe5\n"
            + "Nxe4 18. Bxe7 Qxe7 19. exd6 Qf6 20. Nbd2 Nxd6 21. Nc4 Nxc4 22. Bxc4 Nb6\n"
            + "23. Ne5 Rae8 24. Bxf7+ Rxf7 25. Nxf7 Rxe1+ 26. Qxe1 Kxf7 27. Qe3 Qg5 28. Qxg5\n"
            + "hxg5 29. b3 Ke6 30. a3 Kd6 31. axb4 cxb4 32. Ra5 Nd5 33. f3 Bc8 34. Kf2 Bf5\n"
            + "35. Ra7 g6 36. Ra6+ Kc5 37. Ke1 Nf4 38. g3 Nxh3 39. Kd2 Kb5 40. Rd6 Kc5 41. Ra6\n"
            + "Nf2 42. g4 Bd3 43. Re6 1/2-1/2\n"

        let immortalGamePGN = try PGN(parse: immortalGame)
        XCTAssertEqual(immortalGamePGN.moves.count, 45)
        XCTAssertEqual(immortalGamePGN.outcome, Game.Outcome._win(._white))
        let returnGamePGN = try PGN(parse: returnGame)
        XCTAssertEqual(returnGamePGN.moves.count, 85)
        XCTAssertEqual(returnGamePGN.outcome, Game.Outcome._draw)

        let immortalGameExportedPGN = try PGN(parse: immortalGamePGN.exported())
        let returnGameExportedPGN = try PGN(parse: returnGamePGN.exported())
        XCTAssertEqual(immortalGameExportedPGN, immortalGamePGN)
        XCTAssertEqual(returnGameExportedPGN, returnGamePGN)
        XCTAssertNotEqual(immortalGameExportedPGN, returnGamePGN)
        XCTAssertNotEqual(returnGameExportedPGN, immortalGamePGN)
    }

}

extension Int {

    static func random(from value: Int) -> Int {
        #if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
            return Int(arc4random_uniform(UInt32(value)))
        #elseif os(Linux)
            srand(.init(time(nil)))
            return Int(rand() % .init(value))
        #else
            fatalError("Unknown OS")
        #endif
    }

}

extension Array {

    func random() -> Element? {
        return !self.isEmpty ? self[.random(from: count)] : nil
    }

}

extension Move {

    func formatted() -> String {
        let result = ".\(start) >>> .\(end)"
        #if swift(>=3)
            return result.lowercased()
        #else
            return result.uppercaseString
        #endif
    }

}

#if swift(>=3)

extension Sequence where Iterator.Element == Move {

    func formatted() -> String {
        let values = map { $0.formatted() }
        let string = values.joined(separator: ", ")
        return "[" + string + "]"
    }

}

#else

extension SequenceType where Generator.Element == Move {

    func formatted() -> String {
        let values = map { $0.formatted() }
        let string = values.joinWithSeparator(", ")
        return "[" + string + "]"
    }

}

#endif
