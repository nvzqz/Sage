//
//  File.swift
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

/// A chess board file.
public enum File: Int, Comparable, CustomStringConvertible {

    /// File "A".
    case A = 1

    /// File "B".
    case B = 2

    /// File "C".
    case C = 3

    /// File "D".
    case D = 4

    /// File "E".
    case E = 5

    /// File "F".
    case F = 6

    /// File "G".
    case G = 7

    /// File "H".
    case H = 8

    /// An array of all files.
    public static var all: [File] {
        return [A, B, C, D, E, F, G, H]
    }

    /// The column index of `self`.
    public var index: Int {
        return rawValue - 1
    }

    /// A textual representation of `self`.
    public var description: String {
        return String(character)
    }

    /// The character value of `self`.
    public var character: Character {
        switch self {
        case A: return "A"
        case B: return "B"
        case C: return "C"
        case D: return "D"
        case E: return "E"
        case F: return "F"
        case G: return "G"
        case H: return "H"
        }
    }

    /// Create an instance from a character value.
    public init?(_ character: Character) {
        switch character {
        case "A", "a": self = A
        case "B", "b": self = B
        case "C", "c": self = C
        case "D", "d": self = D
        case "E", "e": self = E
        case "F", "f": self = F
        case "G", "g": self = G
        case "H", "h": self = H
        default: return nil
        }
    }

    /// Create a `File` from a zero-based column index.
    public init?(column index: Int) {
        self.init(rawValue: index + 1)
    }

    /// The next file after `self`.
    public func next() -> File? {
        return File(rawValue: rawValue.successor())
    }

    /// The previous file to `self`.
    public func previous() -> File? {
        return File(rawValue: rawValue.predecessor())
    }

    /// The files from `self` to `other`.
    public func to(other: File) -> [File] {
        if other > self {
            return (rawValue...other.rawValue)
                .flatMap({ File(rawValue: $0) })
        } else if other < self {
            return (other.rawValue...rawValue)
                .reverse()
                .flatMap({ File(rawValue: $0) })
        } else {
            return []
        }
    }

    /// The files between `self` and `other`.
    public func between(other: File) -> [File] {
        if other > self {
            return (rawValue.successor() ..< other.rawValue)
                .flatMap({ File(rawValue: $0) })
        } else if other < self {
            return (other.rawValue.successor() ..< rawValue)
                .reverse()
                .flatMap({ File(rawValue: $0) })
        } else {
            return []
        }
    }

}

extension File: ExtendedGraphemeClusterLiteralConvertible {

    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: Character) {
        guard let file = File(value) else {
            fatalError("File value not within \"A\" and \"H\" or \"a\" and \"h\", inclusive")
        }
        self = file
    }

    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.init(unicodeScalarLiteral: value)
    }

}

/// Returns `true` if one file is further left than the other.
public func < (lhs: File, rhs: File) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
