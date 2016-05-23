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
public enum File: Character {

    /// File "A".
    case A = "A"

    /// File "B".
    case B = "B"

    /// File "C".
    case C = "C"

    /// File "D".
    case D = "D"

    /// File "E".
    case E = "E"

    /// File "F".
    case F = "F"

    /// File "G".
    case G = "G"

    /// File "H".
    case H = "H"

    /// An array of all files.
    public static var all: [File] {
        return [A, B, C, D, E, F, G, H]
    }

    /// Create a `File` from a case-insensitive `Character` raw value.
    public init?(rawValue: Character) {
        switch rawValue {
        case "A", "a":
            self = A
        case "B", "b":
            self = B
        case "C", "c":
            self = C
        case "D", "d":
            self = D
        case "E", "e":
            self = E
        case "F", "f":
            self = F
        case "G", "g":
            self = G
        case "H", "h":
            self = H
        default:
            return nil
        }
    }

    /// Create a `File` from a zero-based column index.
    public init?(column index: Int) {
        guard 0...7 ~= index else {
            return nil
        }
        self.init(rawValue: Character(UnicodeScalar(65 + index)))
    }

}

extension File: ExtendedGraphemeClusterLiteralConvertible {

    /// Create an instance initialized to `value`.
    public init(unicodeScalarLiteral value: Character) {
        guard let file = File(rawValue: value) else {
            fatalError("File value not within \"A\" and \"H\" or \"a\" and \"h\", inclusive")
        }
        self = file
    }

    /// Create an instance initialized to `value`.
    public init(extendedGraphemeClusterLiteral value: Character) {
        self.init(unicodeScalarLiteral: value)
    }

}
