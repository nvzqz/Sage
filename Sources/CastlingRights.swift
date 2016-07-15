//
//  CastlingRights.swift
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

/// Castling rights of a `Game`.
///
/// Defines whether a `Color` has the right to castle for a `Board.Side`.
public struct CastlingRights: CustomStringConvertible {

    /// A castling right.
    public enum Right: String, CustomStringConvertible {

        #if swift(>=3)

        /// White can castle kingside.
        case whiteKingside

        /// White can castle queenside.
        case whiteQueenside

        /// Black can castle kingside.
        case blackKingside

        /// Black can castle queenside.
        case blackQueenside

        /// All rights.
        public static let all: [Right] = [.whiteKingside, .whiteQueenside, .blackKingside, .blackQueenside]

        #else

        /// White can castle kingside.
        case WhiteKingside

        /// White can castle queenside.
        case WhiteQueenside

        /// Black can castle kingside.
        case BlackKingside

        /// Black can castle queenside.
        case BlackQueenside

        /// All rights.
        public static let all: [Right] = [.WhiteKingside, .WhiteQueenside, .BlackKingside, .BlackQueenside]

        #endif

        /// The color for `self`.
        public var color: Color {
            get {
                #if swift(>=3)
                    switch self {
                    case .whiteKingside, .whiteQueenside:
                        return .white
                    default:
                        return .black
                    }
                #else
                    switch self {
                    case .WhiteKingside, .WhiteQueenside:
                        return .White
                    default:
                        return .Black
                    }
                #endif
            }
            set {
                self = Right(color: newValue, side: side)
            }
        }

        /// The board side for `self`.
        public var side: Board.Side {
            get {
                #if swift(>=3)
                    switch self {
                    case .whiteKingside, .blackKingside:
                        return .kingside
                    default:
                        return .queenside
                    }
                #else
                    switch self {
                    case .WhiteKingside, .BlackKingside:
                        return .Kingside
                    default:
                        return .Queenside
                    }
                #endif
            }
            set {
                self = Right(color: color, side: side)
            }
        }

        /// The squares expected to be empty for a castle.
        public var emptySquares: Bitboard {
            #if swift(>=3)
                switch self {
                case .whiteKingside:
                    return 0b01100000
                case .whiteQueenside:
                    return 0b00001110
                case .blackKingside:
                    return 0b01100000 << 56
                case .blackQueenside:
                    return 0b00001110 << 56
                }
            #else
                switch self {
                case .WhiteKingside:
                    return 0b01100000
                case .WhiteQueenside:
                    return 0b00001110
                case .BlackKingside:
                    return 0b01100000 << 56
                case .BlackQueenside:
                    return 0b00001110 << 56
                }
            #endif
        }

        /// The castle destination square of a king.
        public var castleSquare: Square {
            #if swift(>=3)
                switch self {
                case .whiteKingside:
                    return .g1
                case .whiteQueenside:
                    return .c1
                case .blackKingside:
                    return .g8
                case .blackQueenside:
                    return .c8
                }
            #else
                switch self {
                case .WhiteKingside:
                    return .G1
                case .WhiteQueenside:
                    return .C1
                case .BlackKingside:
                    return .G8
                case .BlackQueenside:
                    return .C8
                }
            #endif
        }

        /// The character for `self`.
        public var character: Character {
            #if swift(>=3)
                switch self {
                case .whiteKingside:  return "K"
                case .whiteQueenside: return "Q"
                case .blackKingside:  return "k"
                case .blackQueenside: return "q"
                }
            #else
                switch self {
                case .WhiteKingside:  return "K"
                case .WhiteQueenside: return "Q"
                case .BlackKingside:  return "k"
                case .BlackQueenside: return "q"
                }
            #endif
        }

        /// A textual representation of `self`.
        public var description: String {
            return rawValue
        }

        private var _bit: Int {
            #if swift(>=3)
                switch self {
                case .whiteKingside:  return 0b0001
                case .whiteQueenside: return 0b0010
                case .blackKingside:  return 0b0100
                case .blackQueenside: return 0b1000
                }
            #else
                switch self {
                case .WhiteKingside:  return 0b0001
                case .WhiteQueenside: return 0b0010
                case .BlackKingside:  return 0b0100
                case .BlackQueenside: return 0b1000
                }
            #endif
        }

        /// Create a `Right` from `color` and `side`.
        public init(color: Color, side: Board.Side) {
            #if swift(>=3)
                switch (color, side) {
                case (.white, .kingside):  self = .whiteKingside
                case (.white, .queenside): self = .whiteQueenside
                case (.black, .kingside):  self = .blackKingside
                case (.black, .queenside): self = .blackQueenside
                }
            #else
                switch (color, side) {
                case (.White, .Kingside):  self = .WhiteKingside
                case (.White, .Queenside): self = .WhiteQueenside
                case (.Black, .Kingside):  self = .BlackKingside
                case (.Black, .Queenside): self = .BlackQueenside
                }
            #endif
        }

        /// Create a `Right` from a `Character`.
        public init?(character: Character) {
            #if swift(>=3)
                switch character {
                case "K": self = .whiteKingside
                case "Q": self = .whiteQueenside
                case "k": self = .blackKingside
                case "q": self = .blackQueenside
                default: return nil
                }
            #else
                switch character {
                case "K": self = .WhiteKingside
                case "Q": self = .WhiteQueenside
                case "k": self = .BlackKingside
                case "q": self = .BlackQueenside
                default: return nil
                }
            #endif
        }

    }

    #if swift(>=3)

    /// An iterator over the members of `CastlingRights`.
    public struct Iterator: IteratorProtocol {

        private var _base: SetIterator<Right>

        /// Advance to the next element and return it, or `nil` if no next element exists.
        public mutating func next() -> Right? {
            return _base.next()
        }

    }

    #else

    /// A generator over the members of `CastlingRights`.
    public struct Generator: GeneratorType {

        private var _base: SetGenerator<Right>

        /// Advance to the next element and return it, or `nil` if no next element exists.
        public mutating func next() -> Right? {
            return _base.next()
        }

    }

    #endif

    /// All castling rights.
    public static let all = CastlingRights(Right.all)

    /// The rights.
    private var _rights: Set<Right>

    /// A textual representation of `self`.
    public var description: String {
        if !_rights.isEmpty {
            #if swift(>=3)
                return String(_rights.map({ $0.character }).sorted())
            #else
                return String(_rights.map({ $0.character }).sort())
            #endif
        } else {
            return "-"
        }
    }

    /// Creates empty rights.
    public init() {
        _rights = Set()
    }

    /// Creates a `CastlingRights` from a `String`.
    ///
    /// - returns: `nil` if `string` is empty or invalid.
    public init?(string: String) {
        guard !string.isEmpty else {
            return nil
        }
        if string == "-" {
            _rights = Set()
        } else {
            var rights = Set<Right>()
            for char in string.characters {
                guard let right = Right(character: char) else {
                    return nil
                }
                rights.insert(right)
            }
            _rights = rights
        }
    }

    #if swift(>=3)

    /// Creates a set of rights from a sequence.
    public init<S: Sequence where S.Iterator.Element == Right>(_ sequence: S) {
        if let set = sequence as? Set<Right> {
            _rights = set
        } else {
            _rights = Set(sequence)
        }
    }

    #else

    /// Creates a set of rights from a sequence.
    public init<S: SequenceType where S.Generator.Element == Right>(_ sequence: S) {
        if let set = sequence as? Set<Right> {
            _rights = set
        } else {
            _rights = Set(sequence)
        }
    }

    #endif

}

#if swift(>=3)

extension CastlingRights: Sequence {

    /// Returns an iterator over the members.
    public func makeIterator() -> Iterator {
        return Iterator(_base: _rights.makeIterator())
    }

}

extension CastlingRights: SetAlgebra {

    /// A Boolean value that indicates whether the set has no elements.
    public var isEmpty: Bool {
        return _rights.isEmpty
    }

    /// Returns a Boolean value that indicates whether the given element exists
    /// in the set.
    public func contains(_ member: Right) -> Bool {
        return _rights.contains(member)
    }

    /// Returns a new set with the elements of both this and the given set.
    public func union(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.union(other._rights))
    }

    /// Returns a new set with the elements that are common to both this set and
    /// the given set.
    public func intersection(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.intersection(other._rights))
    }

    /// Returns a new set with the elements that are either in this set or in the
    /// given set, but not in both.
    public func symmetricDifference(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.symmetricDifference(other._rights))
    }

    /// Inserts the given element in the set if it is not already present.
    @discardableResult
    public mutating func insert(_ newMember: Right) -> (inserted: Bool, memberAfterInsert: Right) {
        return _rights.insert(newMember)
    }

    /// Removes the given element and any elements subsumed by the given element.
    @discardableResult
    public mutating func remove(_ member: Right) -> Right? {
        return _rights.remove(member)
    }

    /// Inserts the given element into the set unconditionally.
    @discardableResult
    public mutating func update(with newMember: Right) -> Right? {
        return _rights.update(with: newMember)
    }

    /// Adds the elements of the given set to the set.
    public mutating func formUnion(_ other: CastlingRights) {
        _rights.formUnion(other._rights)
    }

    /// Removes the elements of this set that aren't also in the given set.
    public mutating func formIntersection(_ other: CastlingRights) {
        _rights.formIntersection(other._rights)
    }

    /// Removes the elements of the set that are also in the given set and
    /// adds the members of the given set that are not already in the set.
    public mutating func formSymmetricDifference(_ other: CastlingRights) {
        _rights.formSymmetricDifference(other._rights)
    }

    /// Returns a new set containing the elements of this set that do not occur
    /// in the given set.
    public func subtracting(_ other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.subtracting(other._rights))
    }

    /// Returns a Boolean value that indicates whether the set is a subset of
    /// another set.
    public func isSubset(of other: CastlingRights) -> Bool {
        return _rights.isSubset(of: other._rights)
    }

    /// Returns a Boolean value that indicates whether the set has no members in
    /// common with the given set.
    public func isDisjoint(with other: CastlingRights) -> Bool {
        return _rights.isDisjoint(with: other._rights)
    }

    /// Returns a Boolean value that indicates whether the set is a superset of
    /// the given set.
    public func isSuperset(of other: CastlingRights) -> Bool {
        return _rights.isSuperset(of: other._rights)
    }

    /// Removes the elements of the given set from this set.
    public mutating func subtract(_ other: CastlingRights) {
        _rights.subtract(other)
    }

}

#else

extension CastlingRights: SequenceType {

    /// Returns a generator over the members.
    ///
    /// - complexity: O(1).
    public func generate() -> Generator {
        return Generator(_base: _rights.generate())
    }

}

extension CastlingRights: SetAlgebraType {

    /// Returns `true` if `self` contains `member`.
    public func contains(member: Right) -> Bool {
        return _rights.contains(member)
    }

    /// Returns the set of elements contained in `self`, in `other`, or in both `self` and `other`.
    @warn_unused_result(mutable_variant="unionInPlace")
    public func union(other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.union(other._rights))
    }

    /// Returns the set of elements contained in both `self` and `other`.
    @warn_unused_result(mutable_variant="intersectInPlace")
    public func intersect(other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.intersect(other._rights))
    }

    /// Returns the set of elements contained in `self` or in `other`, but not in both `self` and `other`.
    @warn_unused_result(mutable_variant="exclusiveOrInPlace")
    public func exclusiveOr(other: CastlingRights) -> CastlingRights {
        return CastlingRights(_rights.exclusiveOr(other._rights))
    }

    /// Insert all elements of `other` into `self`.
    public mutating func unionInPlace(other: CastlingRights) {
        _rights.unionInPlace(other._rights)
    }

    /// Removes all elements of `self` that are not also present in `other`.
    public mutating func intersectInPlace(other: CastlingRights) {
        _rights.intersectInPlace(other._rights)
    }

    /// Replaces `self` with a set containing all elements contained in either `self` or `other`, but not both.
    public mutating func exclusiveOrInPlace(other: CastlingRights) {
        _rights.exclusiveOrInPlace(other._rights)
    }

    /// If `member` is not already contained in `self`, inserts it.
    public mutating func insert(member: Right) {
        _rights.insert(member)
    }

    /// Remove the member from the set and return it if it was present.
    public mutating func remove(member: Right) -> Right? {
        return _rights.remove(member)
    }

}

#endif

extension CastlingRights: Hashable {
    /// The hash value.
    public var hashValue: Int {
        return _rights.reduce(0, combine: { $0 | $1._bit })
    }
}

/// Returns `true` if both have the same rights.
public func == (lhs: CastlingRights, rhs: CastlingRights) -> Bool {
    return lhs._rights == rhs._rights
}
