//
//  CastlingAvailabilities.swift
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

/// Castling availabilities of a `Game`.
public struct CastlingAvailabilities: SetAlgebraType, CustomStringConvertible {

    /// A castling availability.
    public enum Availability: String, CustomStringConvertible {

        /// White can castle kingside.
        case WhiteKingside

        /// White can castle queenside.
        case WhiteQueenside

        /// Black can castle kingside.
        case BlackKingside

        /// Black can castle queenside.
        case BlackQueenside

        /// All availabilities.
        public static var all: [Availability] {
            return [.WhiteKingside, .WhiteQueenside,
                    .BlackKingside, .BlackQueenside]
        }

        /// The color for `self`.
        public var color: Color {
            switch self {
            case .WhiteKingside, .WhiteQueenside:
                return .White
            default:
                return .Black
            }
        }

        /// The character for `self`.
        public var character: Character {
            switch self {
            case .WhiteKingside:
                return "K"
            case .WhiteQueenside:
                return "Q"
            case .BlackKingside:
                return "k"
            case .BlackQueenside:
                return "q"
            }
        }

        /// A textual representation of `self`.
        public var description: String {
            return rawValue
        }

        private var _bit: Int {
            switch self {
            case .WhiteKingside:  return 0b0001
            case .WhiteQueenside: return 0b0010
            case .BlackKingside:  return 0b0100
            case .BlackQueenside: return 0b1000
            }
        }

        /// Create an `Availability` from a `Character`.
        public init?(character: Character) {
            switch character {
            case "K": self = .WhiteKingside
            case "Q": self = .WhiteQueenside
            case "k": self = .BlackKingside
            case "q": self = .BlackQueenside
            default: return nil
            }
        }

    }

    /// All castling availabilities.
    public static let all = CastlingAvailabilities(Availability.all)

    /// The availabilities.
    private var _availabilities: Set<Availability>

    /// A textual representation of `self`.
    public var description: String {
        if !_availabilities.isEmpty {
            return String(_availabilities.map({ $0.character }).sort())
        } else {
            return "-"
        }
    }

    /// Creates an empty set of availabilities.
    public init() {
        _availabilities = Set()
    }

    /// Creates `CastlingAvailabilities` from a `String`.
    ///
    /// - Returns: `nil` if `string` is empty or invalid.
    public init?(string: String) {
        guard !string.isEmpty else {
            return nil
        }
        if string == "-" {
            _availabilities = Set()
        } else {
            var availabilities = Set<Availability>()
            for char in string.characters {
                guard let availability = Availability(character: char) else {
                    return nil
                }
                availabilities.insert(availability)
            }
            _availabilities = availabilities
        }
    }

    /// Creates a set of availabilities from a sequence.
    public init<S: SequenceType where S.Generator.Element == Availability>(_ sequence: S) {
        if let set = sequence as? Set<Availability> {
            _availabilities = set
        } else {
            _availabilities = Set(sequence)
        }
    }

    /// Returns `true` if `self` contains `member`.
    @warn_unused_result
    public func contains(member: Availability) -> Bool {
        return _availabilities.contains(member)
    }

    /// Returns the set of elements contained in `self`, in `other`, or in
    /// both `self` and `other`.
    @warn_unused_result(mutable_variant="unionInPlace")
    public func union(other: CastlingAvailabilities) -> CastlingAvailabilities {
        return CastlingAvailabilities(_availabilities.union(other._availabilities))
    }

    /// Returns the set of elements contained in both `self` and `other`.
    @warn_unused_result(mutable_variant="intersectInPlace")
    public func intersect(other: CastlingAvailabilities) -> CastlingAvailabilities {
        return CastlingAvailabilities(_availabilities.intersect(other._availabilities))
    }

    /// Returns the set of elements contained in `self` or in `other`,
    /// but not in both `self` and `other`.
    @warn_unused_result(mutable_variant="exclusiveOrInPlace")
    public func exclusiveOr(other: CastlingAvailabilities) -> CastlingAvailabilities {
        return CastlingAvailabilities(_availabilities.exclusiveOr(other._availabilities))
    }

    /// Insert all elements of `other` into `self`.
    public mutating func unionInPlace(other: CastlingAvailabilities) {
        _availabilities.unionInPlace(other._availabilities)
    }

    /// Removes all elements of `self` that are not also present in
    /// `other`.
    public mutating func intersectInPlace(other: CastlingAvailabilities) {
        _availabilities.unionInPlace(other._availabilities)
    }

    /// Replaces `self` with a set containing all elements contained in
    /// either `self` or `other`, but not both.
    public mutating func exclusiveOrInPlace(other: CastlingAvailabilities) {
        _availabilities.exclusiveOrInPlace(other._availabilities)
    }

    /// If `member` is not already contained in `self`, inserts it.
    public mutating func insert(member: Availability) {
        _availabilities.insert(member)
    }

    /// If `member` is contained in `self`, removes and returns it.
    /// Otherwise, removes all elements subsumed by `member` and returns
    /// `nil`.
    ///
    /// - Postcondition: `self.intersect([member]).isEmpty`
    public mutating func remove(member: Availability) -> Availability? {
        return _availabilities.remove(member)
    }

}

extension CastlingAvailabilities: Hashable {
    /// The hash value.
    public var hashValue: Int {
        return _availabilities.reduce(0, combine: { $0 | $1._bit })
    }
}

/// Returns `true` if both have the same availabilities.
public func == (lhs: CastlingAvailabilities, rhs: CastlingAvailabilities) -> Bool {
    return lhs._availabilities == rhs._availabilities
}
