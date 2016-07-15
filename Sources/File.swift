//
//  File.swift
//  Sage
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
/// Files refer to the eight columns of a chess board, beginning with A and ending with H from left to right.
public enum File: Int, Comparable, CustomStringConvertible {

    /// A direction in file.
    public enum Direction {

        #if swift(>=3)

        /// Left direction.
        case left

        /// Right direction.
        case right

        #else

        /// Left direction.
        case Left

        /// Right direction.
        case Right

        #endif

    }

    #if swift(>=3)

    /// File "A".
    case a = 1

    /// File "B".
    case b = 2

    /// File "C".
    case c = 3

    /// File "D".
    case d = 4

    /// File "E".
    case e = 5

    /// File "F".
    case f = 6

    /// File "G".
    case g = 7

    /// File "H".
    case h = 8

    #else

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

    #endif

}

extension File {

    #if swift(>=3)

    /// An array of all files.
    public static let all: [File] = [.a, .b, .c, .d, .e, .f, .g, .h]

    #else

    /// An array of all files.
    public static let all: [File] = [.A, .B, .C, .D, .E, .F, .G, .H]

    #endif

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
        #if swift(>=3)
            switch self {
            case .a: return "a"
            case .b: return "b"
            case .c: return "c"
            case .d: return "d"
            case .e: return "e"
            case .f: return "f"
            case .g: return "g"
            case .h: return "h"
            }
        #else
            switch self {
            case .A: return "a"
            case .B: return "b"
            case .C: return "c"
            case .D: return "d"
            case .E: return "e"
            case .F: return "f"
            case .G: return "g"
            case .H: return "h"
            }
        #endif
    }

    /// Create an instance from a character value.
    public init?(_ character: Character) {
        #if swift(>=3)
            switch character {
            case "A", "a": self = .a
            case "B", "b": self = .b
            case "C", "c": self = .c
            case "D", "d": self = .d
            case "E", "e": self = .e
            case "F", "f": self = .f
            case "G", "g": self = .g
            case "H", "h": self = .h
            default: return nil
            }
        #else
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
        #endif
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
        return File(rawValue: (rawValue + 1))
    }

    /// The previous file to `self`.
    public func previous() -> File? {
        return File(rawValue: (rawValue - 1))
    }

    /// The opposite file of `self`.
    public func opposite() -> File {
        return File(rawValue: 9 - rawValue)!
    }

    /// The files from `self` to `other`.
    public func to(_ other: File) -> [File] {
        if other > self {
            return (rawValue...other.rawValue).flatMap(File.init(rawValue:))
        } else if other < self {
            #if swift(>=3)
                let values = (other.rawValue...rawValue).reversed()
            #else
                let values = (other.rawValue...rawValue).reverse()
            #endif
            return values.flatMap(File.init(rawValue:))
        } else {
            return [self]
        }
    }

    /// The files between `self` and `other`.
    public func between(_ other: File) -> [File] {
        if other > self {
            return (rawValue + 1 ..< other.rawValue).flatMap(File.init(rawValue:))
        } else if other < self {
            #if swift(>=3)
                let values = (other.rawValue + 1 ..< rawValue).reversed()
            #else
                let values = (other.rawValue + 1 ..< rawValue).reverse()
            #endif
            return values.flatMap(File.init(rawValue:))
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
