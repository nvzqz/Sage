//
//  PGNParsingTests.swift
//  Sage
//
//  Created by Kajetan Dąbrowski on 07/10/2016.
//  Copyright © 2016 Nikolai Vazquez. All rights reserved.
//

import Foundation
import XCTest
@testable import Sage

class PGNParsingTests: XCTestCase {

	let moves: [PGNMove] = ["e4", "e5", "Nf3", "Nc6", "Bc4", "Nge7", "O-O", "f6", "Qe2", "d5",
	                       "b3", "Qd6", "Na3", "Be6", "Rb1", "O-O-O", "Bxd5", "Qxd5", "exd5", "Nf5",
	                       "d6", "Nfd4", "d7+", "Kb8", "Qa6", "Re8", "d8=Q+", "Nxd8", "Qxa7+", "Kxa7",
	                       "Bb2", "N8c6", "Rfc1", "Rd8", "Ra1", "Rd5", "Rf1", "Bxa3", "Nxd4", "e4",
	                       "f4", "exf3", "Rxf3", "Rhd8", "d3", "R5d6", "Bxa3", "Nxd4", "Bxd6", "Rf8",
	                       "Bxf8", "Nc6", "Rf5", "Bf7", "Bc5+", "Ka8", "Rd5", "Nd8", "Rxd8#"]

	let fens: [String] = ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
	                      "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
	                      "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
	                      "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2",
	                      "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
	                      "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
	                      "r1bqkb1r/ppppnppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
	                      "r1bqkb1r/ppppnppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1 b kq - 5 4",
	                      "r1bqkb1r/ppppn1pp/2n2p2/4p3/2B1P3/5N2/PPPP1PPP/RNBQ1RK1 w kq - 0 5",
	                      "r1bqkb1r/ppppn1pp/2n2p2/4p3/2B1P3/5N2/PPPPQPPP/RNB2RK1 b kq - 1 5",
	                      "r1bqkb1r/ppp1n1pp/2n2p2/3pp3/2B1P3/5N2/PPPPQPPP/RNB2RK1 w kq d6 0 6",
	                      "r1bqkb1r/ppp1n1pp/2n2p2/3pp3/2B1P3/1P3N2/P1PPQPPP/RNB2RK1 b kq - 0 6",
	                      "r1b1kb1r/ppp1n1pp/2nq1p2/3pp3/2B1P3/1P3N2/P1PPQPPP/RNB2RK1 w kq - 1 7",
	                      "r1b1kb1r/ppp1n1pp/2nq1p2/3pp3/2B1P3/NP3N2/P1PPQPPP/R1B2RK1 b kq - 2 7",
	                      "r3kb1r/ppp1n1pp/2nqbp2/3pp3/2B1P3/NP3N2/P1PPQPPP/R1B2RK1 w kq - 3 8",
	                      "r3kb1r/ppp1n1pp/2nqbp2/3pp3/2B1P3/NP3N2/P1PPQPPP/1RB2RK1 b kq - 4 8",
	                      "2kr1b1r/ppp1n1pp/2nqbp2/3pp3/2B1P3/NP3N2/P1PPQPPP/1RB2RK1 w - - 5 9",
	                      "2kr1b1r/ppp1n1pp/2nqbp2/3Bp3/4P3/NP3N2/P1PPQPPP/1RB2RK1 b - - 0 9",
	                      "2kr1b1r/ppp1n1pp/2n1bp2/3qp3/4P3/NP3N2/P1PPQPPP/1RB2RK1 w - - 0 10",
	                      "2kr1b1r/ppp1n1pp/2n1bp2/3Pp3/8/NP3N2/P1PPQPPP/1RB2RK1 b - - 0 10",
	                      "2kr1b1r/ppp3pp/2n1bp2/3Ppn2/8/NP3N2/P1PPQPPP/1RB2RK1 w - - 1 11",
	                      "2kr1b1r/ppp3pp/2nPbp2/4pn2/8/NP3N2/P1PPQPPP/1RB2RK1 b - - 0 11",
	                      "2kr1b1r/ppp3pp/2nPbp2/4p3/3n4/NP3N2/P1PPQPPP/1RB2RK1 w - - 1 12",
	                      "2kr1b1r/pppP2pp/2n1bp2/4p3/3n4/NP3N2/P1PPQPPP/1RB2RK1 b - - 0 12",
	                      "1k1r1b1r/pppP2pp/2n1bp2/4p3/3n4/NP3N2/P1PPQPPP/1RB2RK1 w - - 1 13",
	                      "1k1r1b1r/pppP2pp/Q1n1bp2/4p3/3n4/NP3N2/P1PP1PPP/1RB2RK1 b - - 2 13",
	                      "1k2rb1r/pppP2pp/Q1n1bp2/4p3/3n4/NP3N2/P1PP1PPP/1RB2RK1 w - - 3 14",
	                      "1k1Qrb1r/ppp3pp/Q1n1bp2/4p3/3n4/NP3N2/P1PP1PPP/1RB2RK1 b - - 0 14",
	                      "1k1nrb1r/ppp3pp/Q3bp2/4p3/3n4/NP3N2/P1PP1PPP/1RB2RK1 w - - 0 15",
	                      "1k1nrb1r/Qpp3pp/4bp2/4p3/3n4/NP3N2/P1PP1PPP/1RB2RK1 b - - 0 15",
	                      "3nrb1r/kpp3pp/4bp2/4p3/3n4/NP3N2/P1PP1PPP/1RB2RK1 w - - 0 16",
	                      "3nrb1r/kpp3pp/4bp2/4p3/3n4/NP3N2/PBPP1PPP/1R3RK1 b - - 1 16",
	                      "4rb1r/kpp3pp/2n1bp2/4p3/3n4/NP3N2/PBPP1PPP/1R3RK1 w - - 2 17",
	                      "4rb1r/kpp3pp/2n1bp2/4p3/3n4/NP3N2/PBPP1PPP/1RR3K1 b - - 3 17",
	                      "3r1b1r/kpp3pp/2n1bp2/4p3/3n4/NP3N2/PBPP1PPP/1RR3K1 w - - 4 18",
	                      "3r1b1r/kpp3pp/2n1bp2/4p3/3n4/NP3N2/PBPP1PPP/R1R3K1 b - - 5 18",
	                      "5b1r/kpp3pp/2n1bp2/3rp3/3n4/NP3N2/PBPP1PPP/R1R3K1 w - - 6 19",
	                      "5b1r/kpp3pp/2n1bp2/3rp3/3n4/NP3N2/PBPP1PPP/R4RK1 b - - 7 19",
	                      "7r/kpp3pp/2n1bp2/3rp3/3n4/bP3N2/PBPP1PPP/R4RK1 w - - 0 20",
	                      "7r/kpp3pp/2n1bp2/3rp3/3N4/bP6/PBPP1PPP/R4RK1 b - - 0 20",
	                      "7r/kpp3pp/2n1bp2/3r4/3Np3/bP6/PBPP1PPP/R4RK1 w - - 0 21",
	                      "7r/kpp3pp/2n1bp2/3r4/3NpP2/bP6/PBPP2PP/R4RK1 b - f3 0 21",
	                      "7r/kpp3pp/2n1bp2/3r4/3N4/bP3p2/PBPP2PP/R4RK1 w - - 0 22",
	                      "7r/kpp3pp/2n1bp2/3r4/3N4/bP3R2/PBPP2PP/R5K1 b - - 0 22",
	                      "3r4/kpp3pp/2n1bp2/3r4/3N4/bP3R2/PBPP2PP/R5K1 w - - 1 23",
	                      "3r4/kpp3pp/2n1bp2/3r4/3N4/bP1P1R2/PBP3PP/R5K1 b - - 0 23",
	                      "3r4/kpp3pp/2nrbp2/8/3N4/bP1P1R2/PBP3PP/R5K1 w - - 1 24",
	                      "3r4/kpp3pp/2nrbp2/8/3N4/BP1P1R2/P1P3PP/R5K1 b - - 0 24",
	                      "3r4/kpp3pp/3rbp2/8/3n4/BP1P1R2/P1P3PP/R5K1 w - - 0 25",
	                      "3r4/kpp3pp/3Bbp2/8/3n4/1P1P1R2/P1P3PP/R5K1 b - - 0 25",
	                      "5r2/kpp3pp/3Bbp2/8/3n4/1P1P1R2/P1P3PP/R5K1 w - - 1 26",
	                      "5B2/kpp3pp/4bp2/8/3n4/1P1P1R2/P1P3PP/R5K1 b - - 0 26",
	                      "5B2/kpp3pp/2n1bp2/8/8/1P1P1R2/P1P3PP/R5K1 w - - 1 27",
	                      "5B2/kpp3pp/2n1bp2/5R2/8/1P1P4/P1P3PP/R5K1 b - - 2 27",
	                      "5B2/kpp2bpp/2n2p2/5R2/8/1P1P4/P1P3PP/R5K1 w - - 3 28",
	                      "8/kpp2bpp/2n2p2/2B2R2/8/1P1P4/P1P3PP/R5K1 b - - 4 28",
	                      "k7/1pp2bpp/2n2p2/2B2R2/8/1P1P4/P1P3PP/R5K1 w - - 5 29",
	                      "k7/1pp2bpp/2n2p2/2BR4/8/1P1P4/P1P3PP/R5K1 b - - 6 29",
	                      "k2n4/1pp2bpp/5p2/2BR4/8/1P1P4/P1P3PP/R5K1 w - - 7 30",
	                      "k2R4/1pp2bpp/5p2/2B5/8/1P1P4/P1P3PP/R5K1 b - - 0 30"]

	func testGameParsingPGNStyleMoves() throws {
		XCTAssertEqual(fens.count, moves.count + 1)
	}

	func testAllMovesInInitialPosition() {
		let initialPosition = Game.Position()
		let possibleMoves: [PGNMove] = ["a3", "a4", "b3", "b4", "Nf3", "e4", "e3", "d4", "Nc3", "Na3", "h3"]
		#if swift(>=3)
		let resultingMoves: [Move] = [Move(start: .a2, end: .a3),
		                              Move(start: .a2, end: .a4),
		                              Move(start: .b2, end: .b3),
		                              Move(start: .b2, end: .b4),
		                              Move(start: .g1, end: .f3),
		                              Move(start: .e2, end: .e4),
		                              Move(start: .e2, end: .e3),
		                              Move(start: .d2, end: .d4),
		                              Move(start: .b1, end: .c3),
		                              Move(start: .b1, end: .a3),
		                              Move(start: .h2, end: .h3)]
		#else
		let resultingMoves: [Move] = [Move(start: .A2, end: .A3),
									  Move(start: .A2, end: .A4),
									  Move(start: .B2, end: .B3),
									  Move(start: .B2, end: .B4),
									  Move(start: .G1, end: .F3),
									  Move(start: .E2, end: .E4),
									  Move(start: .E2, end: .E3),
									  Move(start: .D2, end: .D4),
									  Move(start: .B1, end: .C3),
									  Move(start: .B1, end: .A3),
									  Move(start: .H2, end: .H3)]

		#endif
		for i in 0..<possibleMoves.count {
			try XCTAssertEqual(PGNParser.parse(move: possibleMoves[i], in: initialPosition), resultingMoves[i])
		}
	}

	#if swift(>=3)

	func testRookMovesParsing() {
		let position = Game.Position(fen: "1kq5/7R/8/8/R2PR2R/8/8/4K2R w - - 0 1")!
		XCTAssertEqual(try? PGNParser.parse(move: "Ra4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rb4+", in: position), Move(start: .a4, end: .b4))
		XCTAssertEqual(try? PGNParser.parse(move: "Rc4", in: position), Move(start: .a4, end: .c4))
		XCTAssertEqual(try? PGNParser.parse(move: "Rd4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Re4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rf4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rg4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rh4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Reg4", in: position), Move(start: .e4, end: .g4))
		XCTAssertEqual(try? PGNParser.parse(move: "Rhg4", in: position), Move(start: .h4, end: .g4))

		XCTAssertEqual(try? PGNParser.parse(move: "Rh8", in: position), Move(start: .h7, end: .h8))
		XCTAssertEqual(try? PGNParser.parse(move: "Rh7", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rh6", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rh6", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rhh6", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "R7h6", in: position), Move(start: .h7, end: .h6))
	}

	#else

	func testRookMovesParsing() {
		let position = Game.Position(fen: "1kq5/7R/8/8/R2PR2R/8/8/4K2R w - - 0 1")!
		XCTAssertEqual(try? PGNParser.parse(move: "Ra4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rb4+", in: position), Move(start: .A4, end: .B4))
		XCTAssertEqual(try? PGNParser.parse(move: "Rc4", in: position), Move(start: .A4, end: .C4))
		XCTAssertEqual(try? PGNParser.parse(move: "Rd4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Re4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rf4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rg4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rh4", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Reg4", in: position), Move(start: .E4, end: .G4))
		XCTAssertEqual(try? PGNParser.parse(move: "Rhg4", in: position), Move(start: .H4, end: .G4))

		XCTAssertEqual(try? PGNParser.parse(move: "Rh8", in: position), Move(start: .H7, end: .H8))
		XCTAssertEqual(try? PGNParser.parse(move: "Rh7", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rh6", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rh6", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "Rhh6", in: position), nil)
		XCTAssertEqual(try? PGNParser.parse(move: "R7h6", in: position), Move(start: .H7, end: .H6))
	}

	#endif

	func testGamePlaysCorrectly() {
		for i in 0..<moves.count {
			do {
				let startFen = fens[i]
				let expectedFen = fens[i+1]
				let startPosition = Game.Position(fen: startFen)!
				let moveString = moves[i]
				let move = try PGNParser.parse(move: moveString, in: startPosition)
				let game = try Game(position: startPosition)
				try game.execute(move: move)
				#if swift(>=3)
				var fenElements = game.position.fen().components(separatedBy: " ")
				_ = fenElements.removeLast()
				let finalFen = fenElements.joined(separator: " ")
				var expectedFenElements = expectedFen.components(separatedBy: " ")
				_ = expectedFenElements.removeLast()
				let finalExpectedFen = expectedFenElements.joined(separator: " ")
				#else
				var fenElements = game.position.fen().componentsSeparatedByString(" ")
				_ = fenElements.removeLast()
				let finalFen = fenElements.joinWithSeparator(" ")
				var expectedFenElements = expectedFen.componentsSeparatedByString(" ")
				_ = expectedFenElements.removeLast()
				let finalExpectedFen = expectedFenElements.joinWithSeparator(" ")
				#endif

				XCTAssertEqual(finalFen, finalExpectedFen)
			} catch {
				XCTFail("\(error)")
			}
		}
	}

	func testPGNValidMoves() {
		let validMoves: [String] = ["e4", "e5", "Nf3", "Nc6", "Bc4", "Nge7", "O-O", "f6", "Qe2", "d5",
		                   "b3", "Qd6", "Na3", "Be6", "Rb1", "O-O-O", "Bxd5", "Qxd5", "exd5", "Nf5",
		                   "d6", "Nfd4", "d7+", "Kb8", "Qa6", "Re8", "d8=Q+", "Nxd8", "Qxa7+", "Kxa7",
		                   "Bb2", "N8c6", "Rfc1", "Rd8", "Ra1", "Rd5", "Rf1", "Bxa3", "Nxd4", "e4",
		                   "f4", "exf3", "Rxf3", "Rhd8", "d3", "R5d6", "Bxa3", "Nxd4", "Bxd6", "Rf8",
		                   "Bxf8", "Nc6", "Rf5", "Bf7", "Bc5+", "Ka8", "Rd5", "Nd8", "Rxd8#"]

		let invalidMoves: [String] = ["r3gr34", "xihwr", "Ld4", "j3", "Rxf9", "😮"]
		for move in validMoves {
			XCTAssertNotNil(PGNMove(rawValue: move))
			XCTAssertEqual(PGNMove(rawValue: move)?.isPossible, true)
		}

		for move in invalidMoves {
			XCTAssertNil(PGNMove(rawValue: move))
		}

		let capture = PGNMove(rawValue: "Nxe6")
		XCTAssertNotNil(capture)
		XCTAssertTrue(capture!.isPossible)
		XCTAssertTrue(capture!.isCapture)
		XCTAssertFalse(capture!.isPromotion)
		XCTAssertNil(capture!.promotionPiece)
		XCTAssertFalse(capture!.isCheck)
		XCTAssertFalse(capture!.isCheckmate)
		XCTAssertEqual(capture!.piece, Piece.Kind._knight)
		XCTAssertFalse(capture!.isCastle)
		XCTAssertEqual(capture!.rank, Rank(6))
		XCTAssertEqual(capture!.file, File._e)
		XCTAssertEqual(capture!.sourceRank, nil)
		XCTAssertEqual(capture!.sourceFile, nil)

		let promotion: PGNMove = "d8=B#"
		XCTAssertTrue(promotion.isPossible)
		XCTAssertFalse(promotion.isCapture)
		XCTAssertTrue(promotion.isPromotion)
		XCTAssertEqual(promotion.promotionPiece, Piece.Kind._bishop)
		XCTAssertTrue(promotion.isCheck)
		XCTAssertTrue(promotion.isCheckmate)
		XCTAssertEqual(promotion.piece, Piece.Kind._pawn)
		XCTAssertFalse(promotion.isCastle)
		XCTAssertEqual(promotion.rank, Rank(8))
		XCTAssertEqual(promotion.file, File._d)
		XCTAssertEqual(promotion.sourceRank, nil)
		XCTAssertEqual(promotion.sourceFile, nil)

		let pawnCapture: PGNMove = "axb4"
		XCTAssertTrue(pawnCapture.isPossible)
		XCTAssertTrue(pawnCapture.isCapture)
		XCTAssertFalse(pawnCapture.isPromotion)
		XCTAssertNil(pawnCapture.promotionPiece)
		XCTAssertFalse(pawnCapture.isCheck)
		XCTAssertFalse(pawnCapture.isCheckmate)
		XCTAssertEqual(pawnCapture.piece, Piece.Kind._pawn)
		XCTAssertFalse(pawnCapture.isCastle)
		XCTAssertEqual(pawnCapture.rank, Rank(4))
		XCTAssertEqual(pawnCapture.file, File._b)
		XCTAssertEqual(pawnCapture.sourceRank, nil)
		XCTAssertEqual(pawnCapture.sourceFile, File._a)

		XCTAssertTrue(PGNMove(rawValue: "O-O-O")!.isCastleQueenside)
		XCTAssertFalse(PGNMove(rawValue: "O-O-O")!.isCastleKingside)
		XCTAssertTrue(PGNMove(rawValue: "O-O-O")!.isCastle)
		XCTAssertFalse(PGNMove(rawValue: "O-O-O")!.isCheck)

		XCTAssertFalse(PGNMove(rawValue: "O-O+")!.isCastleQueenside)
		XCTAssertTrue(PGNMove(rawValue: "O-O+")!.isCastleKingside)
		XCTAssertTrue(PGNMove(rawValue: "O-O+")!.isCastle)
		XCTAssertTrue(PGNMove(rawValue: "O-O+")!.isCheck)
	}

	#if swift(>=3)

	func testParserShouldNotCrashOnInvalidMoves() {
		let game = Game()
		XCTAssertThrowsError(try game.execute(move: "aiuw"))
		XCTAssertThrowsError(try game.execute(move: ""))
		XCTAssertThrowsError(try game.execute(move: "a#"))
		XCTAssertThrowsError(try game.execute(move: "a"))
		XCTAssertThrowsError(try game.execute(move: "w"))
		XCTAssertThrowsError(try game.execute(move: "!3"))
		XCTAssertThrowsError(try game.execute(move: "ad"))
		XCTAssertThrowsError(try game.execute(move: "aB"))
		XCTAssertThrowsError(try game.execute(move: "B3"))
		XCTAssertThrowsError(try game.execute(move: "x"))
		XCTAssertThrowsError(try game.execute(move: "1"))
		XCTAssertThrowsError(try game.execute(move: "🍣"))
		XCTAssertThrowsError(try game.execute(move: "VASF234df89ayrsdfiuafiuawf"))
	}

	#endif
}
