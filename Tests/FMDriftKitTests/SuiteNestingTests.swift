import Foundation
import Testing

@testable import FMDriftKit

/// Deeply nested suites must fail with a message, not overflow the stack. Yams composes the
/// node tree recursively; a few hundred nested flow mappings used to crash `validate` and `run`.
@Suite("Suite nesting")
struct SuiteNestingTests {
    enum Shape: String, CaseIterable, Sendable {
        case flowSequence, flowMapping, blockMapping, blockSequence

        /// A suite whose case schema nests `depth` levels in this shape.
        func suite(depth: Int) -> String {
            let head = "cases:\n  - id: a\n    prompt: p\n    schema:"
            switch self {
            case .flowSequence:
                return head + " " + String(repeating: "[", count: depth) + String(repeating: "]", count: depth) + "\n"
            case .flowMapping:
                return head + " " + String(repeating: "{a: ", count: depth) + "x" + String(repeating: "}", count: depth)
                    + "\n"
            case .blockMapping:
                // One more space of indentation per level.
                let lines = (0..<depth).map { String(repeating: " ", count: 5 + $0) + "a:" }
                return head + "\n" + lines.joined(separator: "\n") + " x\n"
            case .blockSequence:
                // Compact nested sequences on one line: `- - - x`.
                return head + "\n     " + String(repeating: "- ", count: depth) + "x\n"
            }
        }
    }

    private func message(_ text: String) -> String {
        do {
            _ = try SuiteLoader.parse(text, file: "deep.yaml")
            return "no error"
        } catch {
            return error.description
        }
    }

    @Test(arguments: Shape.allCases, [300, 990, 1000])
    func refusesDeepNesting(shape: Shape, depth: Int) {
        let text = shape.suite(depth: depth)
        #expect(text.utf8.count <= SuiteLoader.maximumFileSize)
        let result = message(text)
        #expect(result.hasPrefix("deep.yaml:"), "\(shape) \(depth): \(result)")
        #expect(result.contains("nests deeper than"), "\(shape) \(depth): \(result)")
    }

    @Test func refusesNestingUpToTheFileSizeLimit() {
        let depth = SuiteLoader.maximumFileSize / 2 - 64
        #expect(message(Shape.flowSequence.suite(depth: depth)).contains("nests deeper than 1000 levels"))
    }

    /// Commands run on Swift concurrency threads, which have the smallest stacks.
    @Test(arguments: Shape.allCases)
    func refusesDeepNestingFromATask(shape: Shape) async {
        let text = shape.suite(depth: 1000)
        let result = await Task.detached { message(text) }.value
        #expect(result.contains("nests deeper than"), "\(shape): \(result)")
    }

    @Test func readsTheDeepestSchemaItAllows() throws {
        var schema = "{ type: string }"
        for _ in 1..<JSONSchema.maximumDepth {
            schema = "{ type: array, items: \(schema) }"
        }
        let suite = try SuiteLoader.parse("cases:\n  - id: a\n    prompt: p\n    schema: \(schema)\n")
        #expect(suite.cases.first?.schema != nil)
    }
}
