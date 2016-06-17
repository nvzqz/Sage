//
//  CastlingAvailability.swift
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

/// The castling availability of a `Game`.
public struct CastlingAvailability: OptionSetType, Equatable, CustomStringConvertible {

    /// No castling availability.
    public static let None = CastlingAvailability(rawValue: 0)

    /// White can castle kingside.
    public static let WhiteKingside = CastlingAvailability(rawValue: 1)

    /// White can castle queenside.
    public static let WhiteQueenside = CastlingAvailability(rawValue: 2)

    /// Black can castle kingside.
    public static let BlackKingside = CastlingAvailability(rawValue: 4)

    /// Black can castle queenside.
    public static let BlackQueenside = CastlingAvailability(rawValue: 8)

    /// Starting castling availability.
    public static let Starting = CastlingAvailability(rawValue: 15)

    /// Array of all individual castling availabilities.
    public static var all: [CastlingAvailability] {
        return [.WhiteKingside, .WhiteQueenside,
                .BlackKingside, .BlackQueenside]
    }

    /// The corresponding `UInt8` value.
    public var rawValue: UInt8

    /// A textual representation of `self`.
    public var description: String {
        var description = ""
        for (a, char) in zip(CastlingAvailability.all, ["K", "Q", "k", "q"]) {
            if self.contains(a) {
                description += char
            }
        }
        return !description.isEmpty ? description : "-"
    }

    /// Convert from a value of `UInt8`, succeeding unconditionally.
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    /// Returns the individual availabilities of `self`.
    public func split() -> [CastlingAvailability] {
        return CastlingAvailability.all.filter(self.contains)
    }

}
