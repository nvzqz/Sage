[![Sage](https://raw.githubusercontent.com/nvzqz/Sage/assets/Banner.png)](https://github.com/nvzqz/Sage)

<p align="center">
<a href="https://developer.apple.com/swift/"><img alt="Swift 2.2 | 3.0" src="https://img.shields.io/badge/swift-2.2%20%7C%203.0-orange.svg"></a>
<img alt="Platforms" src="https://img.shields.io/badge/platform-ios%20%7C%20macos%20%7C%20watchos%20%7C%20tvos%20%7C%20linux-lightgrey.svg">
<a href="https://cocoapods.org/pods/Sage"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/Sage.svg"></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
<a href="https://swift.org/package-manager/"><img alt="Swift Package Manager" src="https://img.shields.io/badge/SPM-compatible-orange.svg"></a>
<a href="https://www.apache.org/licenses/LICENSE-2.0"><img alt="Apache 2.0 License" src="https://img.shields.io/badge/license-Apache%202.0-000000.svg"></a>
</p>

Sage is a cross-platform chess library for Swift.

- [Features](#features)
- [Installation](#installation)
    - [Compatibility](#compatibility)
    - [Swift Package Manager](#install-using-swift-package-manager)
    - [CocoaPods](#install-using-cocoapods)
    - [Carthage](#install-using-carthage)
- [Usage](#usage)
    - [Game Management](#game-management)
    - [Move Generation](#move-generation)
    - [Move Validation](#move-validation)
    - [Undo and Redo Moves](#undo-and-redo-moves)
    - [Promotion Handling](#promotion-handling)
    - [Pretty Printing](#pretty-printing)
    - [Forsyth–Edwards Notation](#forsythedwards-notation)
    - [Iterating Through a Board](#iterating-through-a-board)
    - [Squares to Moves](#squares-to-moves)
    - [Playground Quick Look](#playground-quick-look)
- [License](#license)

## Features

- [x] Chess game management
- [x] Chess board structuring
- [x] Move generation / validation
- [x] En passant and castling
- [x] Pawn promotions
- [x] FEN for games and boards
- [x] [Documentation](https://nvzqz.github.io/Sage/docs/)

## Installation

### Compatibility

- Platforms:
    - macOS 10.9+
    - iOS 8.0+
    - watchOS 2.0+
    - tvOS 9.0+
    - Linux
- Xcode 7.3 and 8.0
- Swift 2.2 and 3.0

### Install Using Swift Package Manager
The [Swift Package Manager](https://swift.org/package-manager/) is a
decentralized dependency manager for Swift.

1. Add the project to your `Package.swift`.

    ```swift
    import PackageDescription

    let package = Package(
        name: "MyAwesomeProject",
        dependencies: [
            .Package(url: "https://github.com/nvzqz/Sage.git",
                     majorVersion: 1)
        ]
    )
    ```

2. Import the Sage module.

    ```swift
    import Sage
    ```

### Install Using CocoaPods
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```ruby
    use_frameworks!

    pod 'Sage', '~> 1.0.0'
    ```

2. Run `pod install` and open the `.xcworkspace` file to launch Xcode.

3. Import the Sage framework.

    ```swift
    import Sage
    ```

### Install Using Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency
manager for Objective-C and Swift.

1. Add the project to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

    ```
    github "nvzqz/Sage"
    ```

2. Run `carthage update` and follow [the additional steps](https://github.com/Carthage/Carthage#getting-started)
   in order to add Sage to your project.

3. Import the Sage framework.

    ```swift
    import Sage
    ```

## Usage

### Game Management

Running a chess game can be as simple as setting up a loop.

```swift
import Sage

let game = Game()

while !game.isFinished {
    let move = ...
    try game.execute(move: move)
}
```

### Move Generation

Sage is capable of generating legal moves for the current player with full
support for special moves such as en passant and castling.

- `availableMoves()` will return all moves currently available.

- `movesForPiece(at:)` will return all moves for a piece at a square.

- `movesBitboardForPiece(at:)` will return a `Bitboard` containing all of the
  squares a piece at a square can move to.

### Move Validation

Sage can also validate whether a move is legal with the `isLegal(move:)`
method for a `Game` state.

The `execute(move:)` family of methods calls this method, so it would be faster
to execute the move directly and catch any error from an illegal move.

### Undo and Redo Moves

Move undo and redo operations are done with the `undoMove()` and `redoMove()`
methods. The undone or redone move is returned.

To just check what moves are to be undone or redone, the `moveToUndo()` and
`moveToRedo()` methods are available.

### Promotion Handling

The `execute(move:promotion:)` method takes a closure that returns a promotion
piece. This allows for the app to prompt the user for a promotion piece or
perform any other operations before choosing a promotion piece.

```swift
try game.execute(move: move) {
    ...
    return .queen(game.playerTurn)
}
```

The closure is only executed if the move is a pawn promotion. An error is thrown
if the promotion piece is the wrong color or cannot promote a pawn, such as with
a king or pawn.

A piece can be given without a closure. The default promotion piece is a queen.

```swift
try game.execute(move: move, promotion: .queen(game.playerTurn))
```

### Pretty Printing

The `Board` and `Bitboard` types both have an `ascii` property that can be used
to print a visual board.

```swift
let board = Board()

print(board.ascii)
//   +-----------------+
// 8 | r n b q k b n r |
// 7 | p p p p p p p p |
// 6 | . . . . . . . . |
// 5 | . . . . . . . . |
// 4 | . . . . . . . . |
// 3 | . . . . . . . . |
// 2 | P P P P P P P P |
// 1 | R N B Q K B N R |
//   +-----------------+
//     a b c d e f g h

print(board.bitboard().ascii)
//   +-----------------+
// 8 | 1 1 1 1 1 1 1 1 |
// 7 | 1 1 1 1 1 1 1 1 |
// 6 | . . . . . . . . |
// 5 | . . . . . . . . |
// 4 | . . . . . . . . |
// 3 | . . . . . . . . |
// 2 | 1 1 1 1 1 1 1 1 |
// 1 | 1 1 1 1 1 1 1 1 |
//   +-----------------+
//     a b c d e f g h
```

### Forsyth–Edwards Notation

The `Game.Position` and `Board` types can both generate a FEN string.

```swift
let game = Game()

print(game.position.fen())
// rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1

print(game.board.fen())
// rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR
```

They can also be initialized from a FEN string.

```swift
assert(Board(fen: game.board.fen()) == game.board)

assert(Game.Position(fen: game.position.fen()) == game.position)
```

### Iterating Through a Board

The `Board` type conforms to `Sequence`, making iterating through its spaces
seamless.

```swift
for space in Board() {
    if let piece = space.piece {
        print("\(piece) at \(space.square)")
    }
}
```

### Squares to Moves

`Sequence` and `Square` have two methods that return an array of moves that go
from/to `self` to/from the parameter.

```swift
print([.a1, .h3, .b5].moves(from: .b4))
// [b4 >>> a1, b4 >>> h3, b4 >>> b5]

print([.c3, .d2, .f1].moves(to: .a6))
// [c3 >>> a6, d2 >>> a6, f1 >>> a6]

print(Square.d4.moves(from: [.c2, .f8, .h2]))
// [c2 >>> d4, f8 >>> d4, h2 >>> d4]

print(Square.a4.moves(to: [.c3, .d4, .f6]))
// [a4 >>> c3, a4 >>> d4, a4 >>> f6]
```

### Playground Quick Look

`Board` conforms to the `CustomPlaygroundQuickLookable` protocol.

![Playground quick look](https://raw.githubusercontent.com/nvzqz/Sage/assets/BoardPlaygroundView.png)

## License

Sage is published under [version 2.0 of the Apache License](https://www.apache.org/licenses/LICENSE-2.0).
