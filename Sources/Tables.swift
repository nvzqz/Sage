//
//  Tables.swift
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

/// Returns the pawn attack table for `color`.
internal func _pawnAttackTable(for color: Color) -> [Bitboard] {
    if color.isWhite {
        return _whitePawnAttackTable
    } else {
        return _blackPawnAttackTable
    }
}

/// A lookup table of all white pawn attack bitboards.
internal let _whitePawnAttackTable = Square.all.map { square in
    return Bitboard(square: square)._pawnAttacks(for: .white)
}

/// A lookup table of all black pawn attack bitboards.
internal let _blackPawnAttackTable = Square.all.map { square in
    return Bitboard(square: square)._pawnAttacks(for: .black)
}

/// A lookup table of all king attack bitboards.
internal let _kingAttackTable = Square.all.map { square in
    return Bitboard(square: square)._kingAttacks()
}

/// A lookup table of all knight attack bitboards.
internal let _knightAttackTable = Square.all.map { square in
    return Bitboard(square: square)._knightAttacks()
}

/// Returns the squares between `start` and `end`.
private func _between(_ start: Square, _ end: Square) -> Bitboard {
    let start = UInt64(start.hashValue)
    let end = UInt64(end.hashValue)
    let max = UInt64.max
    let a2a7: UInt64 = 0x0001010101010100
    let b2g7: UInt64 = 0x0040201008040200
    let h1b7: UInt64 = 0x0002040810204080

    let between = (max << start) ^ (max << end)
    let file = (end & 7) &- (start & 7)
    let rank = ((end | 7) &- start) >> 3

    var line = ((file & 7) &- 1) & a2a7
    line += 2 &* (((rank & 7) &- 1) >> 58)
    line += (((rank &- file) & 15) &- 1) & b2g7
    line += (((rank &+ file) & 15) &- 1) & h1b7
    line = line &* (between & (0 &- between))

    return Bitboard(rawValue: line & between)
}

/// Returns the triangle index for `start` and `end`.
internal func _triangleIndex(_ start: Square, _ end: Square) -> Int {
    var a = start.hashValue
    var b = end.hashValue
    var d = a &- b
    d &= d >> 31
    b = b &+ d
    a = a &- d
    b = b &* (b ^ 127)
    return (b >> 1) + a
}

/// A lookup table of squares between two squares.
internal let _betweenTable: [Bitboard] = {

    var table = [Bitboard](repeating: 0, count: 2080)

    for start in Square.all {
        for end in Square.all {
            let index = _triangleIndex(start, end)
            table[index] = _between(start, end)
        }
    }
    return table
}()

/// A lookup table of lines for two squares.
internal let _lineTable: [Bitboard] = {

    var table = [Bitboard](repeating: 0, count: 2080)

    for start in Square.all {
        for end in Square.all {
            let startBB = Bitboard(square: start)
            let endBB = Bitboard(square: end)
            let index = _triangleIndex(start, end)
            let rookAttacks = startBB._rookAttacks()
            let bishopAttacks = startBB._bishopAttacks()
            if rookAttacks[end] {
                table[index] = startBB | endBB | (rookAttacks & endBB._rookAttacks())
            } else if bishopAttacks[end] {
                table[index] = startBB | endBB | (bishopAttacks & endBB._bishopAttacks())
            }
        }
    }
    return table
}()
