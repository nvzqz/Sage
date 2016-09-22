# Change Log

All releases of Sage adhere to [Semantic Versioning](http://semver.org/).

## [v2.5.2](https://github.com/nvzqz/Sage/tree/v2.5.2) (2016-09-21)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.5.1...v2.5.2)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.5.2)

### Fixes

- Fixes issue regarding legal move generation for king in check due to error in moves available for the attacking piece

## [v2.5.1](https://github.com/nvzqz/Sage/tree/v2.5.1) (2016-08-17)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.5.0...v2.5.1)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.5.1)

### Fixes

- Swift 3 preview 6 and Xcode 8 beta 6 compatibility

## [v2.5.0](https://github.com/nvzqz/Sage/tree/v2.5.0) (2016-08-17)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.4.1...v2.5.0)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.5.0)

### New Features

- Added pinned(for:) method to Board

- Added `between(_:)`, `isBetween(start:end:)` and `line(with:)` methods to Square

- Added `hasMoreThanOne` to Bitboard

### Enhancements

- Made legal move generation/checking faster for king pieces

### Fixes

- Fixed conditions for castling so that a king cannot castle in check and it can't castle through squares that are being attacked

## [v2.4.1](https://github.com/nvzqz/Sage/tree/v2.4.1) (2016-08-06)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.4.0...v2.4.1)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.4.1)

### Fixes

- Swift 3 preview 4 and Xcode 8 beta 4 compatibility

## [v2.4.0](https://github.com/nvzqz/Sage/tree/v2.4.0) (2016-08-06)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.3.0...v2.4.0)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.4.0)

### New Features

- Added `init(position:whitePlayer:blackPlayer:variant:)` to `Game`

### Enhancements

- Greatly improved performance of `attackers(to:color:)` method for `Board`

- Improved performance for `pieceCount(for:)` for `Board`

- Improved performance for `contains(_:)` for `Bitboard`

## [v2.3.0](https://github.com/nvzqz/Sage/tree/v2.3.0) (2016-07-31)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.2.0...v2.3.0)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.3.0)

### New Features

- Added `captureForLastMove` to Game

## [v2.2.0](https://github.com/nvzqz/Sage/tree/v2.2.0) (2016-07-30)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.1.0...v2.2.0)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.2.0)

### New Features

- Added `execute(uncheckedMove:)` family of methods to `Game`

- Added initializer with moves array to Game

### Enhancements

- Improved performance for `bitboard(for color: Color)` method for `Board`

## [v2.1.0](https://github.com/nvzqz/Sage/tree/v2.1.0) (2016-07-24)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.0.1...v2.1.0)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.1.0)

### New Features

- Added static `white`, `black`, `kingside`, and `queenside` constants to `CastlingRights` and `CastlingRights.Right`

- Added `canCastle(for:)` methods to `CastlingRights` that take a `Color` or `Board.Side`

- Added `init(color:)` and `init(side:)` to `CastlingRights`

## [v2.0.1](https://github.com/nvzqz/Sage/tree/v2.0.1) (2016-07-21)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v2.0.0...v2.0.1)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.0.1)

### Fixes

- Fixed Xcode 8 beta 3 warnings for guard statements

## [v2.0.0](https://github.com/nvzqz/Sage/tree/v2.0.0) (2016-07-17)

- [Full Changelog](https://github.com/nvzqz/Sage/compare/v1.0.0...v2.0.0)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v2.0.0)

### Enhancements

- Performance greatly improved when performing operations with `Board`

### New Features

- Most significant bit operations to `Bitboard`:

    - Properties: `msb`, `msbIndex`, `msbSquare`

    - Methods: `popMSB()`, `popMSBIndex()`, `popMSBSquare()`

- `Board` initializer from arrays of piece characters
    ```swift
    Board(pieces: [["r", "n", "b", "q", "k", "b", "n", "r"],
                   ["p", "p", "p", "p", "p", "p", "p", "p"],
                   [" ", " ", " ", " ", " ", " ", " ", " "],
                   [" ", " ", " ", " ", " ", " ", " ", " "],
                   [" ", " ", " ", " ", " ", " ", " ", " "],
                   [" ", " ", " ", " ", " ", " ", " ", " "],
                   ["P", "P", "P", "P", "P", "P", "P", "P"],
                   ["R", "N", "B", "Q", "K", "B", "N", "R"]])
    ```

- Parsing PGN string data with `PGN(parse:)`

- Exporting PGN string data with `exported()`

- New `Player` struct

### Breaking Changes

- `Piece` has been changed to a struct type with nested a `Kind` type

    - Values such as `isKing` and `relativeValue` now belong to `Kind`

- The argument-less `bitboard()` method for `Board` has been changed to `occupiedSpaces`

- Replaced `Game.Mode` with two `Player` instances for a game

### Fixes

- Calling `redoMove()` would sometimes cause a crash if the `Game` instance had no available moves (e.g. was over).

- The `Board` playground view for iOS and tvOS was flipped vertically

- `canPromote(_:)` for `Piece` didn't take king into account

- Castling rights weren't restored in `undoMove()`

- `execute(move:)` didn't check the promotion piece's kind


## [v1.0.0](https://github.com/nvzqz/Sage/tree/v1.0.0) (2016-07-03)

- [Release](https://github.com/nvzqz/Sage/releases/tag/v1.0.0)

Initial release
