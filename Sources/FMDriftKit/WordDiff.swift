import Foundation

/// A word-level diff of two outputs, for showing what a new model says differently.
public enum WordDiff {
    public enum Operation: String, Sendable, Codable {
        case equal
        case removed
        case added
    }

    public struct Segment: Sendable, Equatable, Codable {
        public var operation: Operation
        public var text: String
    }

    /// Longer inputs are not diffed word by word; the LCS table grows with the product.
    public static let maximumWords = 600

    /// Segments that turn `old` into `new`; nil when either side has more than ``maximumWords``.
    public static func segments(from old: String, to new: String) -> [Segment]? {
        let a = tokens(old)
        let b = tokens(new)
        guard a.count <= maximumWords, b.count <= maximumWords else { return nil }

        // lengths[i][j] = LCS length of a[i...] and b[j...].
        var lengths = [[Int]](repeating: [Int](repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in stride(from: a.count - 1, through: 0, by: -1) {
            for j in stride(from: b.count - 1, through: 0, by: -1) {
                lengths[i][j] = a[i] == b[j] ? lengths[i + 1][j + 1] + 1 : max(lengths[i + 1][j], lengths[i][j + 1])
            }
        }
        var segments: [Segment] = []
        func emit(_ operation: Operation, _ text: String) {
            if let last = segments.last, last.operation == operation {
                segments[segments.count - 1].text += text
            } else {
                segments.append(Segment(operation: operation, text: text))
            }
        }
        var i = 0
        var j = 0
        while i < a.count, j < b.count {
            if a[i] == b[j] {
                emit(.equal, a[i])
                i += 1
                j += 1
            } else if lengths[i + 1][j] >= lengths[i][j + 1] {
                emit(.removed, a[i])
                i += 1
            } else {
                emit(.added, b[j])
                j += 1
            }
        }
        while i < a.count {
            emit(.removed, a[i])
            i += 1
        }
        while j < b.count {
            emit(.added, b[j])
            j += 1
        }
        return segments
    }

    /// Words with the whitespace that follows them, so joining the tokens gives the text back.
    static func tokens(_ text: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var inSpace = false
        for character in text {
            let isSpace = character.isWhitespace
            if inSpace, !isSpace {
                tokens.append(current)
                current = ""
            }
            inSpace = isSpace
            current.append(character)
        }
        if !current.isEmpty { tokens.append(current) }
        return tokens
    }
}
