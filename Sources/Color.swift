//
//  Color.swift
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

/// A chess color.
public enum Color: String, CustomStringConvertible {

    /// White chess color.
    case White

    /// Black chess color.
    case Black

    /// Whether the color is white or not.
    public var isWhite: Bool {
        return self == .White
    }

    /// Whether the color is black or not.
    public var isBlack: Bool {
        return self == .Black
    }

    /// A textual representation of `self`.
    public var description: String {
        return rawValue
    }

    /// The lowercase character for the color. `White` is "w", `Black` is "b".
    public var character: Character {
        return self.isWhite ? "w" : "b"
    }

    /// Create a color from a character of any case.
    public init?(character: Character) {
        switch character {
        case "W", "w": self = .White
        case "B", "b": self = .Black
        default: return nil
        }
    }

    /// Returns the inverse of `self`.
    @warn_unused_result(mutable_variant="invert")
    public func inverse() -> Color {
        switch self {
        case .White: return .Black
        case .Black: return .White
        }
    }

    /// Inverts the color of `self`.
    public mutating func invert() {
        self = inverse()
    }

}
