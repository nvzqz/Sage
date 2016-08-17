//
//  InternalTypes.swift
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

#if os(OSX)
    import Cocoa
    internal typealias _View = NSView
    internal typealias _Color = NSColor
#elseif os(iOS) || os(tvOS)
    import UIKit
    internal typealias _View = UIView
    internal typealias _Color = UIColor
#endif

internal extension Optional {

    var _altDescription: String {
        #if swift(>=3)
            return self.map({ String(describing: $0) }) ?? "nil"
        #else
            return self.map({ String($0) }) ?? "nil"
        #endif
    }

}

extension RawRepresentable where RawValue == Int, Self: Comparable {

    internal func _to(_ other: Self) -> [Self] {
        if other > self {
            return (rawValue...other.rawValue).flatMap(Self.init(rawValue:))
        } else if other < self {
            #if swift(>=3)
                let values = (other.rawValue...rawValue).reversed()
            #else
                let values = (other.rawValue...rawValue).reverse()
            #endif
            return values.flatMap(Self.init(rawValue:))
        } else {
            return [self]
        }
    }

    internal func _between(_ other: Self) -> [Self] {
        if other > self {
            return (rawValue + 1 ..< other.rawValue).flatMap(Self.init(rawValue:))
        } else if other < self {
            #if swift(>=3)
                let values = (other.rawValue + 1 ..< rawValue).reversed()
            #else
                let values = (other.rawValue + 1 ..< rawValue).reverse()
            #endif
            return values.flatMap(Self.init(rawValue:))
        } else {
            return []
        }
    }

}
