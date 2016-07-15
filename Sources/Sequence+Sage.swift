//
//  Sequence+Sage.swift
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

#if swift(>=3)

extension Sequence where Iterator.Element == Square {

    /// Returns moves from `square` to the squares in `self`.
    public func moves(from square: Square) -> [Move] {
        return self.map({ square >>> $0 })
    }

    /// Returns moves from the squares in `self` to `square`.
    public func moves(to square: Square) -> [Move] {
        return self.map({ $0 >>> square })
    }

}

#else

extension SequenceType where Generator.Element == Square {

    /// Returns moves from `square` to the squares in `self`.
    public func moves(from square: Square) -> [Move] {
        return self.map({ square >>> $0 })
    }

    /// Returns moves from the squares in `self` to `square`.
    public func moves(to square: Square) -> [Move] {
        return self.map({ $0 >>> square })
    }

}

#endif
