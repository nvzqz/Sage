//
//  PGNMove.swift
//  Sage
//
//  Created by Kajetan Dąbrowski on 19/10/2016.
//  Copyright © 2016 Nikolai Vazquez. All rights reserved.
//

import Foundation

#if swift(>=3)

/// A PGN move representation in a string.
public struct PGNMove: RawRepresentable, ExpressibleByStringLiteral {


	/// PGN Move parsing error
	///
	/// - invalidMove: The move is invalid
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

	private var match: NSTextCheckingResult?
	private var unwrappedMatch: NSTextCheckingResult {
		guard let unwrappedMatch = match else {
			fatalError("PGNMove not possible. Check move.isPossible before checking other properties")
		}
		return unwrappedMatch
	}

	public init?(rawValue: String) {
		self.rawValue = rawValue
		parse()
		if !isPossible { return nil }
	}

	public init(stringLiteral value: StringLiteralType) {
		rawValue = value
		parse()
	}

	public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
		rawValue = value
		parse()
	}

	public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
		rawValue = value
		parse()
	}

	mutating private func parse() {
		let matches = PGNMove.regex.matches(in: rawValue, options: [], range: fullRange)
		match = matches.filter { $0.range.length == self.fullRange.length }.first
	}

	private var fullRange: NSRange {
		return NSRange(location: 0, length: rawValue.characters.count)
	}

	/// Indicates whether the move is possible.
	public var isPossible: Bool {
		return match != nil
	}

	/// Indicated whether the pgn represents a capture
	public var isCapture: Bool {
		return unwrappedMatch.rangeAt(4).length > 0
	}

	/// Indicates whether the move represents a promotion
	public var isPromotion: Bool {
		return unwrappedMatch.rangeAt(7).length > 0
	}

	/// Indicates whether the move is castle
	public var isCastle: Bool {
		return isCastleKingside || isCastleQueenside
	}

	/// Indicates whether the move is castle kingside
	public var isCastleKingside: Bool {
		return unwrappedMatch.rangeAt(8).length > 0
	}

	/// Indicates whether the move is castle queenside
	public var isCastleQueenside: Bool {
		return unwrappedMatch.rangeAt(9).length > 0
	}

	/// Indicates whether the move represents a check
	public var isCheck: Bool {
		return unwrappedMatch.rangeAt(10).length > 0
	}

	/// Indicates whether the move represents a checkmate
	public var isCheckmate: Bool {
		return stringAt(rangeIndex: 10) == "#"
	}

	/// A piece kind that is moved by the move
	public var piece: Piece.Kind {
		let pieceLetter = stringAt(rangeIndex: 1)
		guard let piece = PGNMove.pieceFor(letter: pieceLetter) else {
			fatalError("Invalid piece")
		}
		return piece
	}

	/// The rank to move to
	public var rank: Rank {
		let rankSymbol = stringAt(rangeIndex: 6)
		guard let raw = Int(rankSymbol), let rank = Rank(rawValue: raw) else { fatalError("Could not get rank") }
		return rank
	}

	/// The file to move to
	public var file: File {
		guard let fileSymbol = stringAt(rangeIndex: 5).characters.first,
			let file = File(fileSymbol) else { fatalError("Could not get file") }
		return file
	}

	/// The rank to move from.
	/// For example in the move 'Nf3' there is no source rank, since PGNMove is out of board context.
	/// However, if you specify the move like 'N4d2' the move will represent the knight from the fourth rank.
	public var sourceRank: Rank? {
		let sourceRankSymbol = stringAt(rangeIndex: 3)
		if sourceRankSymbol == "" { return nil }
		guard let sourceRankRaw = Int(sourceRankSymbol),
			let sourceRank = Rank(rawValue: sourceRankRaw) else { fatalError("Could not get source rank") }
		return sourceRank
	}

	/// The file to move from.
	/// For example in the move 'Nf3' there is no source file, since PGNMove is out of board context.
	/// However, if you specify the move like 'Nfd2' the move will represent the knight from the d file.
	public var sourceFile: File? {
		let sourceFileSymbol = stringAt(rangeIndex: 2)
		if sourceFileSymbol == "" { return nil }
		guard let sourceFileRaw = sourceFileSymbol.characters.first,
			let sourceFile = File(sourceFileRaw) else { fatalError("Could not get source file") }
		return sourceFile
	}

	/// Represents a piece that the move wants to promote to
	public var promotionPiece: Piece.Kind? {
		if !isPromotion { return nil }
		guard let pieceLetter = stringAt(rangeIndex: 7).characters.last,
			let piece = PGNMove.pieceFor(letter: String(pieceLetter)) else { fatalError("Could not get promotion piece") }
		return piece
	}

	private static func pieceFor(letter: String) -> Piece.Kind? {
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
			return nil
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



	/// Parses the move in context of the game position
	///
	/// - parameter move:     Move that needs to be parsed
	/// - parameter position: position to parse in
	///
	/// - throws: Errors if move is invalid, or if it cannot be executed in this position, or if it's ambiguous.
	///
	/// - returns: Parsed move that can be applied to a game (containing source and destination squares)
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

#else

/// A PGN move representation in a string.
public struct PGNMove: RawRepresentable, StringLiteralConvertible {


	/// PGN Move parsing error
	///
	/// - invalidMove: The move is invalid
	public enum ParseError: ErrorType {
		case invalidMove(String)
	}

	public typealias RawValue = String
	public typealias StringLiteralType = String
	public typealias ExtendedGraphemeClusterLiteralType = String
	public typealias UnicodeScalarLiteralType = String
	public let rawValue: String

	static private let pattern = "^(?:([NBRQK]?)([a-h]?)([1-8]?)(x?)([a-h])([1-8])((?:=[NBRQ])?)|(O-O)|(O-O-O))([+#]?)$"
	static private let regex: NSRegularExpression! = try? NSRegularExpression(pattern: pattern, options: [])

	private var match: NSTextCheckingResult?
	private var unwrappedMatch: NSTextCheckingResult {
		guard let unwrappedMatch = match else {
			fatalError("PGNMove not possible. Check move.isPossible before checking other properties")
		}
		return unwrappedMatch
	}

	public init?(rawValue: String) {
		self.rawValue = rawValue
		parse()
		if !isPossible { return nil }
	}

	public init(stringLiteral value: StringLiteralType) {
		rawValue = value
		parse()
	}

	public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
		rawValue = value
		parse()
	}

	public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
		rawValue = value
		parse()
	}

	mutating private func parse() {
		let matches = PGNMove.regex.matchesInString(rawValue, options: [], range: fullRange)
		match = matches.filter { $0.range.length == self.fullRange.length }.first
	}

	private var fullRange: NSRange {
		return NSRange(location: 0, length: rawValue.characters.count)
	}

	/// Indicates whether the move is possible.
	public var isPossible: Bool {
		return match != nil
	}

	/// Indicated whether the pgn represents a capture
	public var isCapture: Bool {
		return unwrappedMatch.rangeAtIndex(4).length > 0
	}

	/// Indicates whether the move represents a promotion
	public var isPromotion: Bool {
		return unwrappedMatch.rangeAtIndex(7).length > 0
	}

	/// Indicates whether the move is castle
	public var isCastle: Bool {
		return isCastleKingside || isCastleQueenside
	}

	/// Indicates whether the move is castle kingside
	public var isCastleKingside: Bool {
		return unwrappedMatch.rangeAtIndex(8).length > 0
	}

	/// Indicates whether the move is castle queenside
	public var isCastleQueenside: Bool {
		return unwrappedMatch.rangeAtIndex(9).length > 0
	}

	/// Indicates whether the move represents a check
	public var isCheck: Bool {
		return unwrappedMatch.rangeAtIndex(10).length > 0
	}

	/// Indicates whether the move represents a checkmate
	public var isCheckmate: Bool {
		return stringAtRangeIndex(10) == "#"
	}

	/// A piece kind that is moved by the move
	public var piece: Piece.Kind {
		let pieceLetter = stringAtRangeIndex(1)
		guard let piece = PGNMove.pieceForLetter(pieceLetter) else {
			fatalError("Invalid piece")
		}
		return piece
	}

	/// The rank to move to
	public var rank: Rank {
		let rankSymbol = stringAtRangeIndex(6)
		guard let raw = Int(rankSymbol), let rank = Rank(rawValue: raw) else { fatalError("Could not get rank") }
		return rank
	}

	/// The file to move to
	public var file: File {
		guard let fileSymbol = stringAtRangeIndex(5).characters.first,
			let file = File(fileSymbol) else { fatalError("Could not get file") }
		return file
	}

	/// The rank to move from.
	/// For example in the move 'Nf3' there is no source rank, since PGNMove is out of board context.
	/// However, if you specify the move like 'N4d2' the move will represent the knight from the fourth rank.
	public var sourceRank: Rank? {
		let sourceRankSymbol = stringAtRangeIndex(3)
		if sourceRankSymbol == "" { return nil }
		guard let sourceRankRaw = Int(sourceRankSymbol),
			let sourceRank = Rank(rawValue: sourceRankRaw) else { fatalError("Could not get source rank") }
		return sourceRank
	}

	/// The file to move from.
	/// For example in the move 'Nf3' there is no source file, since PGNMove is out of board context.
	/// However, if you specify the move like 'Nfd2' the move will represent the knight from the d file.
	public var sourceFile: File? {
		let sourceFileSymbol = stringAtRangeIndex(2)
		if sourceFileSymbol == "" { return nil }
		guard let sourceFileRaw = sourceFileSymbol.characters.first,
			let sourceFile = File(sourceFileRaw) else { fatalError("Could not get source file") }
		return sourceFile
	}

	/// Represents a piece that the move wants to promote to
	public var promotionPiece: Piece.Kind? {
		if !isPromotion { return nil }
		guard let pieceLetter = stringAtRangeIndex(7).characters.last,
			let piece = PGNMove.pieceForLetter(String(pieceLetter)) else { fatalError("Could not get promotion piece") }
		return piece
	}

	private static func pieceForLetter(letter: String) -> Piece.Kind? {
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
			return nil
		}
	}

	private func stringAtRangeIndex(rangeIndex: Int) -> String {
		guard let match = match else { fatalError() }
		let range = match.rangeAtIndex(rangeIndex)
		let substring = (rawValue as NSString).substringWithRange(range)
		return substring
	}
}

public struct PGNParser {



	/// Parses the move in context of the game position
	///
	/// - parameter move:     Move that needs to be parsed
	/// - parameter position: position to parse in
	///
	/// - throws: Errors if move is invalid, or if it cannot be executed in this position, or if it's ambiguous.
	///
	/// - returns: Parsed move that can be applied to a game (containing source and destination squares)
	public static func parse(move move: PGNMove, in position: Game.Position) throws -> Move {
		if !move.isPossible { throw PGNMove.ParseError.invalidMove(move.rawValue) }
		let colorToMove = position.playerTurn
		if move.isCastleKingside { return Move(castle: colorToMove, direction: .Right) }
		if move.isCastleQueenside { return Move(castle: colorToMove, direction: .Left) }

		let piece = Piece(kind: move.piece, color: colorToMove)
		let destinationSquare: Square = Square(file: move.file, rank: move.rank)
		let game = try Game(position: position)
		var possibleMoves = game.availableMoves().filter { return $0.end == destinationSquare }.filter { move -> Bool in
			game.board.locations(for: piece).contains { move.start.location == $0 }
		}

		if let sourceFile = move.sourceFile { possibleMoves = possibleMoves.filter { $0.start.file == sourceFile } }
		if let sourceRank = move.sourceRank { possibleMoves = possibleMoves.filter { $0.start.rank == sourceRank } }

		if possibleMoves.count != 1 { throw PGNMove.ParseError.invalidMove(move.rawValue) }
		return possibleMoves.first!
	}
}

#endif
