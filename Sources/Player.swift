//
//  Player.swift
//  Sage
//
//  Copyright 2016-2017 Nikolai Vazquez
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

/// A chess game player.
public struct Player: Equatable, CustomStringConvertible {

    /// A player kind.
    public enum Kind: String, CustomStringConvertible {

        /// Human player kind.
        case human = "Human"

        /// Computer player kind.
        case computer = "Computer"

        /// Boolean indicating `self` is a human.
        public var isHuman: Bool {
            return self == .human
        }

        /// Boolean indicating `self` is a computer.
        public var isComputer: Bool {
            return self == .computer
        }

        /// A textual representation of this instance.
        public var description: String {
            return rawValue
        }

    }

    /// The the player's kind.
    public var kind: Kind

    /// The player's name.
    public var name: String?

    /// The player's elo rating.
    public var elo: UInt?

    /// A textual representation of this instance.
    public var description: String {
        return "Player(kind: \(kind), name: \(name._altDescription), elo: \(elo._altDescription))"
    }

    /// Create a player with `kind` and `name`.
    ///
    /// - parameter kind: The player's kind. Default is human.
    /// - parameter name: The player's name. Default is `nil`.
    /// - parameter elo: The player's elo rating. Default is `nil`.
    public init(kind: Kind = .human, name: String? = nil, elo: UInt? = nil) {
        self.kind = kind
        self.name = name
        self.elo = elo
    }

}

/// Returns `true` if the players are the same.
public func == (lhs: Player, rhs: Player) -> Bool {
    return lhs.kind == rhs.kind
            && lhs.name == rhs.name
            && lhs.elo == rhs.elo
}
