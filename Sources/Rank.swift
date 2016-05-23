//
//  Rank.swift
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

/// A chess board rank.
public enum Rank: Int, IntegerLiteralConvertible {

    /// Rank 1.
    case One = 1

    /// Rank 2.
    case Two = 2

    /// Rank 3.
    case Three = 3

    /// Rank 4.
    case Four = 4

    /// Rank 5.
    case Five = 5

    /// Rank 6.
    case Six = 6

    /// Rank 7.
    case Seven = 7

    /// Rank 8.
    case Eight = 8

    /// Create an instance from an integer value.
    public init?(_ value: Int) {
        self.init(rawValue: value)
    }

    /// Create an instance initialized to `value`.
    public init(integerLiteral value: Int) {
        guard let rank = Rank(rawValue: value) else {
            fatalError("Rank value not within 1 and 8, inclusive")
        }
        self = rank
    }

}
