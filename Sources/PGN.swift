//
//  PGN.swift
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

/// Portable game notation data.
///
/// - seealso: [Portable Game Notation (Wikipedia)](https://en.wikipedia.org/wiki/Portable_Game_Notation),
///            [PGN Specification](https://www.chessclub.com/user/help/PGN-spec)
public struct PGN {

    /// PGN tag.
    public enum Tag: String, CustomStringConvertible {

        #if swift(>=3)

        /// Event tag.
        case event = "Event"

        /// Site tag.
        case site = "Site"

        /// Date tag.
        case date = "Date"

        /// Round tag.
        case round = "Round"

        /// White tag.
        case white = "White"

        /// Black tag.
        case black = "Black"

        /// Result tag.
        case result = "Result"

        /// Annotator tag.
        case annotator = "Annotator"

        /// Ply (moves) count tag.
        case plyCount = "PlyCount"

        /// TimeControl tag.
        case timeControl = "TimeControl"

        /// Time tag.
        case time = "Time"

        /// Termination tag.
        case termination = "Termination"

        /// Playing mode tag.
        case mode = "Mode"

        /// FEN tag.
        case fen = "FEN"

        /// White player's title tag.
        case whiteTitle = "WhiteTitle"

        /// Black player's title tag.
        case blackTitle = "BlackTitle"

        /// White player's elo rating tag.
        case whiteElo = "WhiteElo"

        /// Black player's elo rating tag.
        case blackElo = "BlackElo"

        /// White player's United States Chess Federation rating tag.
        case whiteUSCF = "WhiteUSCF"

        /// Black player's United States Chess Federation rating tag.
        case blackUSCF = "BlackUSCF"

        /// White player's network or email address tag.
        case whiteNA = "WhiteNA"

        /// Black player's network or email address tag.
        case blackNA = "BlackNA"

        /// White player's type tag; either human or program.
        case whiteType = "WhiteType"

        /// Black player's type tag; either human or program.
        case blackType = "BlackType"

        /// The starting date tag of the event.
        case eventDate = "EventDate"

        /// Tag for the name of the sponsor of the event.
        case eventSponsor = "EventSponsor"

        /// The playing section tag of a tournament.
        case section = "Section"

        /// Tag for the stage of a multistage event.
        case stage = "Stage"

        /// The board number tag in a team event or in a simultaneous exhibition.
        case board = "Board"

        /// The traditional opening name tag.
        case opening = "Opening"

        /// Tag used to further refine the opening tag.
        case variation = "Variation"

        /// Used to further refine the variation tag.
        case subVariation = "SubVariation"

        /// Tag used for an opening designation from the five volume *Encyclopedia of Chess Openings*.
        case eco = "ECO"

        /// Tag used for an opening designation from the *New in Chess* database.
        case nic = "NIC"

        /// Tag similar to the Time tag but given according to the Universal Coordinated Time standard.
        case utcTime = "UTCTime"

        /// Tag similar to the Date tag but given according to the Universal Coordinated Time standard.
        case utcDate = "UTCDate"

        /// Tag for the "set-up" status of the game.
        case setUp = "SetUp"

        #else

        /// Event tag.
        case Event

        /// Site tag.
        case Site

        /// Date tag.
        case Date

        /// Round tag.
        case Round

        /// White tag.
        case White

        /// Black tag.
        case Black

        /// Result tag.
        case Result

        /// Annotator tag.
        case Annotator

        /// Ply (moves) count tag.
        case PlyCount

        /// TimeControl tag.
        case TimeControl

        /// Time tag.
        case Time

        /// Termination tag.
        case Termination

        /// Playing mode tag.
        case Mode

        /// FEN tag.
        case FEN

        /// White player's title tag.
        case WhiteTitle

        /// Black player's title tag.
        case BlackTitle

        /// White player's elo rating tag.
        case WhiteElo

        /// Black player's elo rating tag.
        case BlackElo

        /// White player's United States Chess Federation rating tag.
        case WhiteUSCF

        /// Black player's United States Chess Federation rating tag.
        case BlackUSCF

        /// White player's network or email address tag.
        case WhiteNA

        /// Black player's network or email address tag.
        case BlackNA

        /// White player's type tag; either human or program.
        case WhiteType

        /// Black player's type tag; either human or program.
        case BlackType

        /// The starting date tag of the event.
        case EventDate

        /// Tag for the name of the sponsor of the event.
        case EventSponsor

        /// The playing section tag of a tournament.
        case Section

        /// Tag for the stage of a multistage event.
        case Stage

        /// The board number tag in a team event or in a simultaneous exhibition.
        case Board

        /// The traditional opening name tag.
        case Opening

        /// Tag used to further refine the opening tag.
        case Variation

        /// Used to further refine the variation tag.
        case SubVariation

        /// Tag used for an opening designation from the five volume *Encyclopedia of Chess Openings*.
        case ECO

        /// Tag used for an opening designation from the *New in Chess* database.
        case NIC

        /// Tag similar to the Time tag but given according to the Universal Coordinated Time standard.
        case UTCTime

        /// Tag similar to the Date tag but given according to the Universal Coordinated Time standard.
        case UTCDate

        /// Tag for the "set-up" status of the game.
        case SetUp

        #endif

        /// A textual representation of `self`.
        public var description: String {
            return rawValue
        }

    }

    #if swift(>=3)

    /// An error thrown by `PGN.init(parse:)`.
    public enum ParseError: ErrorProtocol {

        /// Unexpected quote found in move text.
        case unexpectedQuote(String)

        /// Unexpected closing brace found outside of comment.
        case unexpectedClosingBrace(String)

        /// No closing brace for comment.
        case noClosingBrace(String)

        /// No closing quote for tag value.
        case noClosingQuote(String)

        /// No closing bracket for tag pair.
        case noClosingBracket(String)

        /// Wrong number of tokens for tag pair.
        case tagPairTokenCount([String])

        /// Incorrect count of parenthesis for recursive annotation variation.
        case parenthesisCountForRAV(String)

    }

    #else

    /// An error thrown by `PGN.init(parse:)`.
    public enum ParseError: ErrorType {

        /// Unexpected quote found in move text.
        case UnexpectedQuote(String)

        /// Unexpected closing brace found outside of comment.
        case UnexpectedClosingBrace(String)

        /// No closing brace for comment.
        case NoClosingBrace(String)

        /// No closing quote for tag value.
        case NoClosingQuote(String)

        /// No closing bracket for tag pair.
        case NoClosingBracket(String)

        /// Wrong number of tokens for tag pair.
        case TagPairTokenCount([String])

        /// Incorrect count of parenthesis for recursive annotation variation.
        case ParenthesisCountForRAV(String)

    }

    #endif

    /// The tag pairs for `self`.
    public var tagPairs: [String: String]

    /// The moves in standard algebraic notation.
    public var moves: [String]

    /// The game outcome.
    public var outcome: Game.Outcome? {
        get {
            #if swift(>=3)
                let resultTag = Tag.result
            #else
                let resultTag = Tag.Result
            #endif
            return self[resultTag].flatMap(Game.Outcome.init)
        }
        set {
            #if swift(>=3)
                let resultTag = Tag.result
            #else
                let resultTag = Tag.Result
            #endif
            self[resultTag] = newValue?.description
        }
    }

    /// Create PGN with `tagPairs` and `moves`.
    public init(tagPairs: [String: String] = [:], moves: [String] = []) {
        self.tagPairs = tagPairs
        self.moves = moves
    }

    /// Create PGN with `tagPairs` and `moves`.
    public init(tagPairs: [Tag: String], moves: [String] = []) {
        self.init(moves: moves)
        for (tag, value) in tagPairs {
            self[tag] = value
        }
    }

    /// Create PGN by parsing `string`.
    ///
    /// - throws: `ParseError` if an error occured while parsing.
    public init(parse string: String) throws {
        self.init()
        if string.isEmpty { return }
        for line in string._splitByNewlines() {
            if line.characters.first == "[" {
                let commentsStripped = try line._commentsStripped(strings: true)
                let (tag, value) = try commentsStripped._tagPair()
                tagPairs[tag] = value
            } else if line.characters.first != "%" {
                let commentsStripped = try line._commentsStripped(strings: false)
                let (moves, outcome) = try commentsStripped._moves()
                self.moves += moves
                if let outcome = outcome {
                    self.outcome = outcome
                }
            }
        }
    }

    /// Get or set the value for `tag`.
    public subscript(tag: Tag) -> String? {
        get {
            return tagPairs[tag.rawValue]
        }
        set {
            tagPairs[tag.rawValue] = newValue
        }
    }

}

private extension Character {

    static let newlines: Set<Character> = ["\u{000A}", "\u{000B}", "\u{000C}", "\u{000D}",
                                           "\u{0085}", "\u{2028}", "\u{2029}"]

    static let whitespaces: Set<Character> = ["\u{0020}", "\u{00A0}", "\u{1680}", "\u{180E}", "\u{2000}",
                                              "\u{2001}", "\u{2002}", "\u{2003}", "\u{2004}", "\u{2005}",
                                              "\u{2006}", "\u{2007}", "\u{2008}", "\u{2009}", "\u{200A}",
                                              "\u{200B}", "\u{202F}", "\u{205F}", "\u{3000}", "\u{FEFF}"]

    static let digits: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    var isDigit: Bool {
        return Character.digits.contains(self)
    }

}

private extension String {

    var _lastIndex: Index {
        #if swift(>=3)
            return index(before: endIndex)
        #else
            return endIndex.predecessor()
        #endif
    }

    @inline(__always)
    func _split(by set: Set<Character>) -> [String] {
        return characters.split(isSeparator: set.contains).map(String.init)
    }

    @inline(__always)
    func _splitByNewlines() -> [String] {
        return _split(by: Character.newlines)
    }

    @inline(__always)
    func _splitByWhitespaces() -> [String] {
        return _split(by: Character.whitespaces)
    }

    @inline(__always)
    func _tagPair() throws -> (String, String) {
        guard characters.last == "]" else {
            #if swift(>=3)
                throw PGN.ParseError.noClosingBracket(self)
            #else
                throw PGN.ParseError.NoClosingBracket(self)
            #endif
        }
        #if swift(>=3)
            let startIndex = index(after: self.startIndex)
            let endIndex = index(before: self.endIndex)
        #else
            let startIndex = self.startIndex.successor()
            let endIndex = self.endIndex.predecessor()
        #endif
        let tokens = self[startIndex ..< endIndex]._split(by: ["\""])
        guard tokens.count == 2 else {
            #if swift(>=3)
                throw PGN.ParseError.tagPairTokenCount(tokens)
            #else
                throw PGN.ParseError.TagPairTokenCount(tokens)
            #endif
        }
        let tagParts = tokens[0]._splitByWhitespaces()
        guard tagParts.count == 1 else {
            #if swift(>=3)
                throw PGN.ParseError.tagPairTokenCount(tagParts)
            #else
                throw PGN.ParseError.TagPairTokenCount(tagParts)
            #endif
        }
        return (tagParts[0], tokens[1])
    }

    @inline(__always)
    func _moves() throws -> (moves: [String], outcome: Game.Outcome?) {
        var stripped = ""
        var ravDepth = 0
        var startIndex = self.startIndex
        let lastIndex = _lastIndex
        for (index, character) in zip(characters.indices, characters) {
            if character == "(" {
                if ravDepth == 0 {
                    stripped += self[startIndex ..< index]
                }
                ravDepth += 1
            } else if character == ")" {
                ravDepth -= 1
                if ravDepth == 0 {
                    #if swift(>=3)
                        startIndex = self.index(after: index)
                    #else
                        startIndex = index.successor()
                    #endif
                }
            } else if index == lastIndex && ravDepth == 0 {
                stripped += self[startIndex ... index]
            }
        }
        guard ravDepth == 0 else {
            #if swift(>=3)
                throw PGN.ParseError.parenthesisCountForRAV(self)
            #else
                throw PGN.ParseError.ParenthesisCountForRAV(self)
            #endif
        }
        let tokens = stripped._split(by: [" ", "."])
        let moves = tokens.filter({ $0.characters.first?.isDigit == false })
        let outcome = tokens.last.flatMap(Game.Outcome.init)
        return (moves, outcome)
    }

    @inline(__always)
    func _commentsStripped(strings consideringStrings: Bool) throws -> String {
        var stripped = ""
        var startIndex = self.startIndex
        let lastIndex = _lastIndex
        var afterEscape = false
        var inString = false
        var inComment = false
        for (index, character) in zip(characters.indices, characters) {
            if character == "\\" {
                afterEscape = true
                continue
            }
            if character == "\"" {
                if !inComment {
                    guard consideringStrings else {
                        #if swift(>=3)
                            throw PGN.ParseError.unexpectedQuote(self)
                        #else
                            throw PGN.ParseError.UnexpectedQuote(self)
                        #endif
                    }
                    if !inString {
                        inString = true
                    } else if !afterEscape {
                        inString = false
                    }
                }
            } else if !inString {
                if character == ";" && !inComment {
                    stripped += self[startIndex ..< index]
                    break
                } else if character == "{" && !inComment {
                    inComment = true
                    stripped += self[startIndex ..< index]
                } else if character == "}" {
                    guard inComment else {
                        #if swift(>=3)
                            throw PGN.ParseError.unexpectedClosingBrace(self)
                        #else
                            throw PGN.ParseError.UnexpectedClosingBrace(self)
                        #endif
                    }
                    inComment = false
                    #if swift(>=3)
                        startIndex = self.index(after: index)
                    #else
                        startIndex = index.successor()
                    #endif
                }
            }
            if index >= startIndex && index == lastIndex && !inComment {
                stripped += self[startIndex ... index]
            }
            afterEscape = false
        }
        guard !inString else {
            #if swift(>=3)
                throw PGN.ParseError.noClosingQuote(self)
            #else
                throw PGN.ParseError.NoClosingQuote(self)
            #endif
        }
        guard !inComment else {
            #if swift(>=3)
                throw PGN.ParseError.noClosingBrace(self)
            #else
                throw PGN.ParseError.NoClosingBrace(self)
            #endif
        }
        return stripped
    }

}
