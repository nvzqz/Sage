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

/// Castling availability of a `Game`.
public struct CastlingAvailability: SetAlgebraType, SequenceType, CustomStringConvertible {

    /// A castling availability option.
    public enum Option: String, CustomStringConvertible {

        /// White can castle kingside.
        case WhiteKingside

        /// White can castle queenside.
        case WhiteQueenside

        /// Black can castle kingside.
        case BlackKingside

        /// Black can castle queenside.
        case BlackQueenside

        /// All options.
        public static var all: [Option] {
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

        /// The board side for `self`.
        public var side: Board.Side {
            switch self {
            case .WhiteKingside, .BlackKingside:
                return .Kingside
            default:
                return .Queenside
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

        /// Create an `Option` from a `Character`.
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

    /// A generator over the members of `CastlingAvailability`.
    public struct Generator: GeneratorType {

        private var _base: SetGenerator<Option>

        /// Advance to the next element and return it, or `nil` if no next
        /// element exists.
        public mutating func next() -> Option? {
            return _base.next()
        }

    }

    /// All castling availability.
    public static let all = CastlingAvailability(Option.all)

    /// The availability.
    private var _availability: Set<Option>

    /// A textual representation of `self`.
    public var description: String {
        if !_availability.isEmpty {
            return String(_availability.map({ $0.character }).sort())
        } else {
            return "-"
        }
    }

    /// Creates an empty availability.
    public init() {
        _availability = Set()
    }

    /// Creates a `CastlingAvailability` from a `String`.
    ///
    /// - Returns: `nil` if `string` is empty or invalid.
    public init?(string: String) {
        guard !string.isEmpty else {
            return nil
        }
        if string == "-" {
            _availability = Set()
        } else {
            var availability = Set<Option>()
            for char in string.characters {
                guard let option = Option(character: char) else {
                    return nil
                }
                availability.insert(option)
            }
            _availability = availability
        }
    }

    /// Creates a set of availability from a sequence.
    public init<S: SequenceType where S.Generator.Element == Option>(_ sequence: S) {
        if let set = sequence as? Set<Option> {
            _availability = set
        } else {
            _availability = Set(sequence)
        }
    }

    /// Returns `true` if `self` contains `member`.
    @warn_unused_result
    public func contains(member: Option) -> Bool {
        return _availability.contains(member)
    }

    /// Returns the set of elements contained in `self`, in `other`, or in
    /// both `self` and `other`.
    @warn_unused_result(mutable_variant="unionInPlace")
    public func union(other: CastlingAvailability) -> CastlingAvailability {
        return CastlingAvailability(_availability.union(other._availability))
    }

    /// Returns the set of elements contained in both `self` and `other`.
    @warn_unused_result(mutable_variant="intersectInPlace")
    public func intersect(other: CastlingAvailability) -> CastlingAvailability {
        return CastlingAvailability(_availability.intersect(other._availability))
    }

    /// Returns the set of elements contained in `self` or in `other`,
    /// but not in both `self` and `other`.
    @warn_unused_result(mutable_variant="exclusiveOrInPlace")
    public func exclusiveOr(other: CastlingAvailability) -> CastlingAvailability {
        return CastlingAvailability(_availability.exclusiveOr(other._availability))
    }

    /// Insert all elements of `other` into `self`.
    public mutating func unionInPlace(other: CastlingAvailability) {
        _availability.unionInPlace(other._availability)
    }

    /// Removes all elements of `self` that are not also present in
    /// `other`.
    public mutating func intersectInPlace(other: CastlingAvailability) {
        _availability.unionInPlace(other._availability)
    }

    /// Replaces `self` with a set containing all elements contained in
    /// either `self` or `other`, but not both.
    public mutating func exclusiveOrInPlace(other: CastlingAvailability) {
        _availability.exclusiveOrInPlace(other._availability)
    }

    /// If `member` is not already contained in `self`, inserts it.
    public mutating func insert(member: Option) {
        _availability.insert(member)
    }

    /// If `member` is contained in `self`, removes and returns it.
    /// Otherwise, removes all elements subsumed by `member` and returns
    /// `nil`.
    ///
    /// - Postcondition: `self.intersect([member]).isEmpty`
    public mutating func remove(member: Option) -> Option? {
        return _availability.remove(member)
    }

    /// Returns a generator over the members.
    ///
    /// - Complexity: O(1).
    public func generate() -> Generator {
        return Generator(_base: _availability.generate())
    }

}

extension CastlingAvailability: Hashable {
    /// The hash value.
    public var hashValue: Int {
        return _availability.reduce(0, combine: { $0 | $1._bit })
    }
}

/// Returns `true` if both have the same availability.
public func == (lhs: CastlingAvailability, rhs: CastlingAvailability) -> Bool {
    return lhs._availability == rhs._availability
}
