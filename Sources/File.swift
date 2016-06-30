//
//  File.swift
//  Fischer
//
//  Copyright 2016 Nikolai Vazquez
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// A chess board file.
///
/// `File`s refer to the eight columns of a chess board, beginning with `A` and ending with `H` from left to right.
public enum File: Int, Comparable, CustomStringConvertible {

    /// A direction in file.
    public enum Direction {

        /// Left direction.
        case Left

        /// Right direction.
        case Right

    }

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
    public static let all: [File] = [.A, .B, .C, .D, .E, .F, .G, .H]

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
        case .A: return "A"
        case .B: return "B"
        case .C: return "C"
        case .D: return "D"
        case .E: return "E"
        case .F: return "F"
        case .G: return "G"
        case .H: return "H"
        }
    }

    /// Create an instance from a character value.
    public init?(_ character: Character) {
        switch character {
        case "A", "a": self = .A
        case "B", "b": self = .B
        case "C", "c": self = .C
        case "D", "d": self = .D
        case "E", "e": self = .E
        case "F", "f": self = .F
        case "G", "g": self = .G
        case "H", "h": self = .H
        default: return nil
        }
    }

    /// Create a `File` from a zero-based column index.
    public init?(index: Int) {
        self.init(rawValue: index + 1)
    }

    /// Returns a rank from advancing `self` by `value`.
    public func advanced(by value: Int) -> File? {
        return File(rawValue: rawValue + value)
    }

    /// The next file after `self`.
    public func next() -> File? {
        return File(rawValue: rawValue.successor())
    }

    /// The previous file to `self`.
    public func previous() -> File? {
        return File(rawValue: rawValue.predecessor())
    }

    /// The opposite file of `self`.
    public func opposite() -> File {
        return File(rawValue: 9 - rawValue)!
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
            return [self]
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
