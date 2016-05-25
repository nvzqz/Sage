//
//  Move.swift
//  Chess
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
public struct Move: Equatable {

    /// The move's start position.
    public var start: Position

    /// The move's end position.
    public var end: Position

    /// The move's change in file.
    public var dx: Int {
        return end.0.index - start.0.index
    }

    /// The move's change in rank.
    public var dy: Int {
        return end.1.index - start.1.index
    }

    /// The move is a real change in position.
    public var isChange: Bool {
        return start != end
    }

    /// The move is diagonal.
    public var isDiagonal: Bool {
        let dx = self.dx
        return dx != 0 && abs(dx) == abs(dy)
    }

    /// The move is horizontal.
    public var isHorizontal: Bool {
        return (start.0 == end.0 && start.1 != end.1)
            || (start.0 != end.0 && start.1 == end.1)
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
        let sf = File(column: 7 - start.0.index)!
        let sr = Rank(row:    7 - start.1.index)!
        let ef = File(column: 7 - end.0.index)!
        let er = Rank(row:    7 - end.1.index)!
        return Move(start: (sf, sr), end: (ef, er))
    }

}

/// Returns `true` if both moves are the same.
@warn_unused_result
public func == (lhs: Move, rhs: Move) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
}
