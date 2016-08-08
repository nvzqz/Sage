//
//  Tables.swift
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
    return Bitboard(square: square)._pawnAttacks(for: ._white)
}

/// A lookup table of all black pawn attack bitboards.
internal let _blackPawnAttackTable = Square.all.map { square in
    return Bitboard(square: square)._pawnAttacks(for: ._black)
}

/// A lookup table of all king attack bitboards.
internal let _kingAttackTable = Square.all.map { square in
    return Bitboard(square: square)._kingAttacks()
}

/// A lookup table of all knight attack bitboards.
internal let _knightAttackTable = Square.all.map { square in
    return Bitboard(square: square)._knightAttacks()
}
