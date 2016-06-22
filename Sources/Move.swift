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

/// A chess move.
public struct Move: Hashable, CustomStringConvertible {

    /// A castle move for a color in a direction.
    @warn_unused_result
    public static func castle(color: Color, direction: File.Direction) -> Move {
        let rank: Rank = color.isWhite ? 1 : 8
        return Move(start: Square(file: .E, rank: rank),
                    end: Square(file: direction == .Left ? .C : .G, rank: rank)
        )
    }

    /// The move's start square.
    public var start: Square

    /// The move's end square.
    public var end: Square

    /// The move's change in file.
    public var fileChange: Int {
        return end.file.rawValue - start.file.rawValue
    }

    /// The move's change in rank.
    public var rankChange: Int {
        return end.rank.rawValue - start.rank.rawValue
    }

    /// The move is a real change in location.
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

    /// The hash value.
    public var hashValue: Int {
        return start.file.hashValue
            + (start.rank.hashValue << 3)
            + (end.file.hashValue << 6)
            + (end.rank.hashValue << 9)
    }

    /// Create a move with start and end squares.
    public init(start: Square, end: Square) {
        self.start = start
        self.end = end
    }

    /// Create a move with start and end locations.
    public init(start: Location, end: Location) {
        self.start = Square(location: start)
        self.end = Square(location: end)
    }

    /// Returns a move with the end and start of `self` reversed.
    @warn_unused_result
    public func reversed() -> Move {
        return Move(start: end, end: start)
    }

    /// Returns the result of rotating `self` 180 degrees.
    @warn_unused_result
    public func rotated() -> Move {
        let s = Square(file: start.file.opposite(),
                       rank: start.rank.opposite())
        let e = Square(file: end.file.opposite(),
                       rank: end.rank.opposite())
        return Move(start: s, end: e)
    }

}

infix operator >>> { }

/// Returns `true` if both moves are the same.
@warn_unused_result
public func == (lhs: Move, rhs: Move) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}

/// Returns a `Move` from the two squares.
@warn_unused_result
public func >>> (start: Square, end: Square) -> Move {
    return Move(start: start, end: end)
}

/// Returns a `Move` from the two locations.
@warn_unused_result
public func >>> (start: Location, rhs: Location) -> Move {
    return Square(location: start) >>> Square(location: rhs)
}
