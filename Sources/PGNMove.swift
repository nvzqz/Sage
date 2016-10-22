//
//  PGNMove.swift
//  Sage
//
//  Created by Kajetan Dąbrowski on 19/10/2016.
//  Copyright © 2016 Nikolai Vazquez. All rights reserved.
//

import Foundation

public struct PGNMove: RawRepresentable, ExpressibleByStringLiteral {

	public enum ParseError: Error {
		case invalidMove(String)
	}

	public typealias RawValue = String
	public typealias StringLiteralType = String
	public typealias ExtendedGraphemeClusterLiteralType = String
	public typealias UnicodeScalarLiteralType = String
	public let rawValue: String

	static private let pattern = "^(?:([NBRQK]?)([a-h]?)([1-8]?)(x?)([a-h])([1-8])((?:=[NBRQ])?)|(O-O)|(O-O-O))([+#]?)$"
	static private let regex: NSRegularExpression! = try? NSRegularExpression(pattern: pattern, options: [])

	var match: NSTextCheckingResult?

	public init?(rawValue: String) {
		self.rawValue = rawValue
		parse()
		if !isPossible { return nil }
	}

	public init(stringLiteral value: String) {
		rawValue = value
		parse()
	}

	public init(unicodeScalarLiteral value: String) {
		rawValue = value
		parse()
	}

	public init(extendedGraphemeClusterLiteral value: String) {
		rawValue = value
		parse()
	}

	mutating private func parse() {
		let matches = PGNMove.regex.matches(in: self.rawValue, options: [], range: self.fullRange)
		self.match = matches.filter { $0.range.length == self.fullRange.length }.first
	}

	var fullRange: NSRange {
		return NSRange(location: 0, length: rawValue.characters.count)
	}

	public var isPossible: Bool {
		return match != nil
	}

	public var isCapture: Bool {
		return match!.rangeAt(4).length > 0
	}

	public var isPromotion: Bool {
		return match!.rangeAt(7).length > 0
	}

	public var isCastle: Bool {
		return isCastleKingside || isCastleQueenside
	}

	public var isCastleKingside: Bool {
		return match!.rangeAt(8).length > 0
	}

	public var isCastleQueenside: Bool {
		return match!.rangeAt(9).length > 0
	}

	public var isCheck: Bool {
		return match!.rangeAt(10).length > 0
	}

	public var isCheckmate: Bool {
		return stringAt(rangeIndex: 10) == "#"
	}

	public var piece: Piece.Kind {
		guard let match = match else { fatalError() }
		let range = match.rangeAt(1)
		let letter = (rawValue as NSString).substring(with: range)
		return PGNMove.pieceFor(letter: letter)
	}

	public var rank: Rank {
		let rankSymbol = stringAt(rangeIndex: 6)
		return Rank(rawValue: Int(rankSymbol)!)!
	}

	public var file: File {
		return File(stringAt(rangeIndex: 5).characters.first!)!
	}

	public var sourceRank: Rank? {
		let sourceRankSymbol = stringAt(rangeIndex: 3)
		if sourceRankSymbol == "" { return nil }
		return Rank(rawValue: Int(sourceRankSymbol)!)!
	}

	public var sourceFile: File? {
		let sourceFileSymbol = stringAt(rangeIndex: 2)
		if sourceFileSymbol == "" { return nil }
		return File(sourceFileSymbol.characters.first!)!
	}


	public var promotionPiece: Piece.Kind? {
		if !isPromotion { return nil }
		return PGNMove.pieceFor(letter: String(stringAt(rangeIndex: 7).characters.last!))
	}

	private static func pieceFor(letter: String) -> Piece.Kind {
		switch letter {
		case "N":
			return ._knight
		case "B":
			return ._bishop
		case "K":
			return ._king
		case "Q":
			return ._queen
		case "R":
			return ._rook
		case "":
			return ._pawn
		default:
			fatalError()
		}
	}

	private func stringAt(rangeIndex: Int) -> String {
		guard let match = match else { fatalError() }
		let range = match.rangeAt(rangeIndex)
		let substring = (rawValue as NSString).substring(with: range)
		return substring
	}
}

public struct PGNParser {
	public static func parse(move: PGNMove, in position: Game.Position) throws -> Move {
		if !move.isPossible { throw PGNMove.ParseError.invalidMove(move.rawValue) }
		let colorToMove = position.playerTurn
		if move.isCastleKingside { return Move(castle: colorToMove, direction: .right) }
		if move.isCastleQueenside { return Move(castle: colorToMove, direction: .left) }

		let piece = Piece(kind: move.piece, color: colorToMove)
		let destinationSquare: Square = Square(file: move.file, rank: move.rank)
		let game = try Game(position: position)
		var possibleMoves = game.availableMoves().filter { return $0.end == destinationSquare }.filter { move -> Bool in
			game.board.locations(for: piece).contains(where: { move.start.location == $0 })
		}

		if let sourceFile = move.sourceFile { possibleMoves = possibleMoves.filter { $0.start.file == sourceFile } }
		if let sourceRank = move.sourceRank { possibleMoves = possibleMoves.filter { $0.start.rank == sourceRank } }


		if possibleMoves.count != 1 { throw PGNMove.ParseError.invalidMove(move.rawValue) }
		return possibleMoves.first!

	}
}
