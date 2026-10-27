import Foundation

/// A suite file that cannot be read, with the file and line it refers to.
public struct SuiteError: Error, Equatable, CustomStringConvertible {
    public var file: String
    public var line: Int?
    public var message: String

    public init(file: String, line: Int? = nil, message: String) {
        self.file = file
        self.line = line
        self.message = message
    }

    public var description: String {
        if let line { return "\(file):\(line): \(message)" }
        return "\(file): \(message)"
    }
}

enum Spelling {
    /// The closest known word within an edit distance of 3, for "did you mean" hints.
    static func suggestion(for word: String, from candidates: some Collection<String>) -> String? {
        let lowered = word.lowercased()
        var best: (word: String, distance: Int)?
        for candidate in candidates {
            let distance = editDistance(lowered, candidate.lowercased())
            if distance <= 3, distance < (best?.distance ?? .max) {
                best = (candidate, distance)
            }
        }
        return best?.word
    }

    static func editDistance(_ first: String, _ second: String) -> Int {
        let a = Array(first.prefix(64))
        let b = Array(second.prefix(64))
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            current[0] = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                current[j] = min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
            }
            swap(&previous, &current)
        }
        return previous[b.count]
    }
}
