//
//  FischerTests.swift
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

import XCTest
import Fischer

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

    func testGameDoubleStep() {
        let game = Game()
        for file in File.all {
            let move = Move(start: Square(location: (file, 2)), end: Square(location: (file, 5)))
            XCTAssertThrowsError(try game.executeMove(move)) { error in
                guard case let MoveExecutionError.WrongMovementKind(piece) = error else {
                    XCTFail("Expected MoveExecutionError.WrongMovementKind(Pawn(White)), got \(error)")
                    return
                }
                XCTAssertEqual(piece, Piece.Pawn(.White))
            }
        }
        do {
            for file in File.all {
                try game.executeMove(Move(start: Square(location: (file, 2)), end: Square(location: (file, 4))))
                try game.executeMove(Move(start: Square(location: (file, 7)), end: Square(location: (file, 5))))
            }
        } catch {
            XCTFail(String(error))
        }
    }

    func testGameEnPassant() {
        let game = Game()
        do {
            try game.executeMove(Move(start: .C2, end: .C4))
            try game.executeMove(Move(start: .C7, end: .C6))
            try game.executeMove(Move(start: .C4, end: .C5))
            try game.executeMove(Move(start: .D7, end: .D5))
            try game.executeMove(Move(start: .C5, end: .D6))
        } catch {
            XCTFail(String(error))
        }
    }

}
