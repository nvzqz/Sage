//
//  InternalTypes.swift
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

/// A result that is either a value or error.
internal enum _Result<V, E: ErrorType> {

    /// A value result.
    case Value(V)

    /// An error result.
    case Error(E)

    /// The value of `self`, or `nil` if `Error`.
    var value: V? {
        if case let Value(value) = self {
            return value
        } else {
            return nil
        }
    }

    /// The error of `self`, or `nil` if `Value`.
    var error: E? {
        if case let Error(error) = self {
            return error
        } else {
            return nil
        }
    }

    /// `self` is a value.
    var isValue: Bool {
        if case Value = self {
            return true
        } else {
            return false
        }
    }

    /// `self` is an error.
    var isError: Bool {
        if case Error = self {
            return true
        } else {
            return false
        }
    }

}
