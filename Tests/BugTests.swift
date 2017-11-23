//
// Created by Werner Altewischer on 23/11/2017.
// Copyright (c) 2017 Nikolai Vazquez. All rights reserved.
//

import Foundation
import XCTest
import Sage

class BugTests: XCTestCase {

    //Test for: https://github.com/nvzqz/Sage/issues/18
    func testIssue18a() throws {
        guard let position = Game.Position(fen: "2K1r3/3P1k2/8/8/8/8/8/2R5 w - - 0 1") else {
            XCTFail("Expected postion to be valid")
            return
        }
        let game = try Game(position: position)
        XCTAssertTrue(game.kingIsChecked)

        let move = Move(start: Square.d7, end: Square.e8)
        try game.execute(move: move, promotion: .queen)

        XCTAssertTrue(game.kingIsChecked, "Expected king to be checked")
    }

    func testIssue18b() throws {
        guard let position = Game.Position(fen: "2K1r3/3P1k2/8/8/8/8/8/2R5 w - - 0 1") else {
            XCTFail("Expected postion to be valid")
            return
        }
        let game = try Game(position: position)
        XCTAssertTrue(game.kingIsChecked)

        let move = Move(start: Square.d7, end: Square.e8)
        try game.execute(move: move, promotion: .knight)

        XCTAssertFalse(game.kingIsChecked, "Expected king to not be checked")
    }

    func testIssue18c() throws {
        guard let position = Game.Position(fen: "2K1r3/3P1k2/8/8/8/8/8/2R5 w - - 0 1") else {
            XCTFail("Expected postion to be valid")
            return
        }
        let game = try Game(position: position)
        XCTAssertTrue(game.kingIsChecked)

        let move = Move(start: Square.d7, end: Square.d8)
        try game.execute(move: move, promotion: .knight)

        XCTAssertTrue(game.kingIsChecked, "Expected king to be checked")
    }

    func testIssue15() throws {
        let game = Game()

        try game.execute(move: Move(start: Square.e2, end: Square.e4))
        try game.execute(move: Move(start: Square.f7, end: Square.f5))
        try game.execute(move: Move(start: Square.e4, end: Square.f5))

        let g7Moves1 = game.availableMoves().filter { (move) -> Bool in
            move.start == Square.g7
        }

        XCTAssertTrue(g7Moves1.count == 2)
        XCTAssertTrue(g7Moves1.contains(Move(start: Square.g7, end: Square.g5)))
        XCTAssertTrue(g7Moves1.contains(Move(start: Square.g7, end: Square.g6)))

        game.undoMove()
        game.redoMove()

        let g7Moves2 = game.availableMoves().filter { (move) -> Bool in
            move.start == Square.g7
        }

        XCTAssertTrue(g7Moves2.count == 2)
        XCTAssertTrue(g7Moves2.contains(Move(start: Square.g7, end: Square.g5)))
        XCTAssertTrue(g7Moves2.contains(Move(start: Square.g7, end: Square.g6)))
    }
}
