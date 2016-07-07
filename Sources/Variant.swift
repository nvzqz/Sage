//
//  Variant.swift
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

/// A chess variant that defines how a `Board` is populated or how a `Game` is played.
public enum Variant {

    #if swift(>=3)

    /// Standard chess.
    case standard

    /// Upside down chess where the piece colors swap starting squares.
    case upsideDown

    /// Standard regardless of Swift version.
    internal static let _standard = Variant.standard

    /// UpsideDown regardless of Swift version.
    internal static let _upsideDown = Variant.upsideDown

    #else

    /// Standard chess.
    case Standard

    /// Upside down chess where the piece colors swap starting squares.
    case UpsideDown

    /// Standard regardless of Swift version.
    internal static let _standard = Variant.Standard

    /// UpsideDown regardless of Swift version.
    internal static let _upsideDown = Variant.UpsideDown

    #endif

    /// `self` is standard variant.
    public var isStandard: Bool {
        return self == ._standard
    }

    /// `self` is upside down variant.
    public var isUpsideDown: Bool {
        return self == ._upsideDown
    }

}
