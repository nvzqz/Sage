//
//  Move.swift
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

/// A chess position.
public typealias Position = (file: File, rank: Rank)

/// A chess move.
public struct Move: Equatable, CustomStringConvertible {

    /// A castle move for a color in a direction.
    @warn_unused_result
    public static func castle(color: Color, direction: File.Direction) -> Move {
        let rank: Rank = color.isWhite ? 1 : 8
        return Move(
            start: (.E, rank),
            end: (direction == .Left ? .C : .G, rank)
        )
    }

    /// The move's start position.
    public var start: Position

    /// The move's end position.
    public var end: Position

    /// The move's change in file.
    public var fileChange: Int {
        return end.file.rawValue - start.file.rawValue
    }

    /// The move's change in rank.
    public var rankChange: Int {
        return end.rank.rawValue - start.rank.rawValue
    }

    /// The move is a real change in position.
    public var isChange: Bool {
        return start != end
    }

    /// The move is diagonal.
    public var isDiagonal: Bool {
        let fileChange = self.fileChange
        return fileChange != 0 && abs(fileChange) == abs(rankChange)
    }

    /// The move is horizontal.
    public var isHorizontal: Bool {
        return start.file != end.file && start.rank == end.rank
    }

    /// The move is vertical.
    public var isVertical: Bool {
        return start.file == end.file && start.rank != end.rank
    }

    /// The move is horizontal or vertical.
    public var isAxial: Bool {
        return isHorizontal || isVertical
    }

    /// The move is leftward.
    public var isLeftward: Bool {
        return end.file < start.file
    }

    /// The move is rightward.
    public var isRightward: Bool {
        return end.file > start.file
    }

    /// The move is downward.
    public var isDownward: Bool {
        return end.rank < start.rank
    }

    /// The move is upward.
    public var isUpward: Bool {
        return end.rank > start.rank
    }

    /// The move is a castle.
    public var isCastle: Bool {
        return start.rank == end.rank
            && (start.rank == 1 || start.rank == 8)
            && start.file == .E
            && abs(fileChange) == 2
    }

    /// The move is a knight jump two spaces horizontally and one space
    /// vertically, or two spaces vertically and one space horizontally.
    public var isKnightJump: Bool {
        let fileChange = abs(self.fileChange)
        let rankChange = abs(self.rankChange)
        return (fileChange == 2 && rankChange == 1)
            || (rankChange == 2 && fileChange == 1)
    }

    /// The move's direction in file, if any.
    public var fileDirection: File.Direction? {
        if self.isLeftward {
            return .Left
        } else if self.isRightward {
            return .Right
        } else {
            return .None
        }
    }

    /// The move's direction in rank, if any.
    public var rankDirection: Rank.Direction? {
        if self.isUpward {
            return .Up
        } else if self.isDownward {
            return .Down
        } else {
            return .None
        }
    }

    /// A textual representation of `self`.
    public var description: String {
        return "\(start.file)\(start.rank) >>> \(end.file)\(end.rank)"
    }

    /// Create a move with start and end positions.
    public init(start: Position, end: Position) {
        self.start = start
        self.end = end
    }

    /// Returns a move with the end and start of `self` reversed.
    @warn_unused_result
    public func reversed() -> Move {
        return Move(start: end, end: start)
    }

    /// Returns the result of rotating `self` 180 degrees.
    @warn_unused_result
    public func rotated() -> Move {
        let sf = File(column: 7 - start.file.index)!
        let sr = Rank(row:    7 - start.rank.index)!
        let ef = File(column: 7 - end.file.index)!
        let er = Rank(row:    7 - end.rank.index)!
        return Move(start: (sf, sr), end: (ef, er))
    }

}

infix operator >>> { }

/// Returns `true` if both moves are the same.
@warn_unused_result
public func == (lhs: Move, rhs: Move) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}

/// Returns a `Move` from the two positions.
@warn_unused_result
public func >>> (start: Position, end: Position) -> Move {
    return Move(start: start, end: end)
}
