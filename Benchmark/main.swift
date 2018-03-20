import Foundation

extension Int {
    static func random(from value: Int) -> Int {
        #if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
            return Int(arc4random_uniform(UInt32(value)))
        #elseif os(Linux)
            srand(.init(time(nil)))
            return Int(rand() % .init(value))
        #else
            fatalError("Unknown OS")
        #endif
    }
}

extension Array {
    var random: Element? {
        return !self.isEmpty ? self[.random(from: count)] : nil
    }
}

var info = [(time: Double, count: Double)]()

for _ in 1...20 {

    var count = 0.0
    let game = Game()
    
        let start = Date()
    

    do {
        while let move = game.availableMoves().random {
            count += 1
            try game.execute(uncheckedMove: move)
        }
    } catch {
        print(error)
        break
    }

    
        let time = Date().timeIntervalSince(start)
    
    info.append((time, count))

}

let perSec = info.map(/)
let averageSecs = perSec.reduce(0) { $0 + $1 } / Double(info.count)
let averageMoves = info.reduce(0) { $0 + $1.1 } / Double(info.count)
let multiplier = 1 / (info.reduce(0) { $0 + $1.0 } / Double(info.count))

print("Benchmark: 1 move in \(averageSecs) seconds")
print("Benchmark: \(averageMoves * multiplier) moves in 1 seconds")
