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

    /// The tag pairs for `self`.
    public var tagPairs: [Tag: String]

    /// The moves in standard algebraic notation.
    public var moves: [String]

    /// Create PGN with `tagPairs`.
    public init(tagPairs: [Tag: String] = [:], moves: [String] = []) {
        self.tagPairs = tagPairs
        self.moves = moves
    }

}
