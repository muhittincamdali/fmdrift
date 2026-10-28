import Foundation
import Yams

/// Reads suite files (YAML, or JSON, which is valid YAML).
///
/// Every key is checked: an unknown key is an error with a "did you mean" hint, because a typo
/// in an assertion would otherwise make a test pass without checking anything.
public enum SuiteLoader {
    /// Larger files are refused before parsing.
    public static let maximumFileSize = 1_048_576
    public static let maximumCases = 500
    public static let maximumRepeat = 100
    public static let maximumPromptLength = 100_000
    /// Upper bound on YAML nodes visited, so aliases that expand exponentially cannot stall the
    /// reader.
    static let maximumNodes = 200_000

    static let topKeys: Set<String> = ["name", "defaults", "cases"]
    static let settingKeys: Set<String> = [
        "instructions", "sampling", "temperature", "maxResponseTokens", "guardrails", "useCase", "repeat",
        "minPassRate",
    ]
    static let caseKeys: Set<String> = settingKeys.union(["id", "prompt", "schema", "expect"])

    /// Reads a suite file. The suite name defaults to the file name without its extension.
    public static func load(contentsOf url: URL) throws(SuiteError) -> Suite {
        let file = url.lastPathComponent
        let data: Data
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let size = attributes[.size] as? Int, size > maximumFileSize {
                throw SuiteError(
                    file: file, message: "is \(size) bytes; suites are limited to \(maximumFileSize) bytes")
            }
            data = try Data(contentsOf: url)
        } catch let error as SuiteError {
            throw error
        } catch {
            throw SuiteError(file: file, message: "cannot be read (\(error.localizedDescription))")
        }
        guard data.count <= maximumFileSize else {
            throw SuiteError(file: file, message: "is larger than \(maximumFileSize) bytes")
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw SuiteError(file: file, message: "is not UTF-8 text")
        }
        let defaultName = url.deletingPathExtension().lastPathComponent
        return try parse(text, file: file, defaultName: defaultName)
    }

    /// Reads suite text. `file` is used in error messages only.
    public static func parse(_ text: String, file: String = "suite", defaultName: String = "suite") throws(SuiteError)
        -> Suite
    {
        guard text.utf8.count <= maximumFileSize else {
            throw SuiteError(file: file, message: "is larger than \(maximumFileSize) bytes")
        }
        return try onLargeStack { compose(text, file: file, defaultName: defaultName) }.get()
    }

    /// libyaml stops at this many nesting levels; Yams composes, and Swift releases, the node
    /// tree with one chain of stack frames per level.
    static let maximumYAMLNesting = 1000
    /// Room for ``maximumYAMLNesting`` levels with a wide margin: a debug build needs less than
    /// 2 MB for them, and a Swift concurrency thread has 512 KB, which 300 nested flow mappings
    /// overflow. Pages are only committed when a deep suite touches them.
    static let parserStackSize = 16 << 20

    /// Runs `body` on a thread with a ``parserStackSize`` stack and waits for it, so the node tree
    /// is built and freed there whatever thread calls `parse`.
    private static func onLargeStack(_ body: @escaping @Sendable () -> Result<Suite, SuiteError>)
        -> Result<Suite, SuiteError>
    {
        let box = ResultBox()
        let finished = DispatchSemaphore(value: 0)
        let thread = Thread {
            box.result = body()
            finished.signal()
        }
        thread.stackSize = parserStackSize
        thread.start()
        finished.wait()
        guard let result = box.result else { preconditionFailure("the suite thread ended without a result") }
        return result
    }

    private static func compose(_ text: String, file: String, defaultName: String) -> Result<Suite, SuiteError> {
        let root: Node?
        do {
            root = try Yams.compose(yaml: text)
        } catch let error as YamlError {
            if case .parser(_, let problem, _, _) = error, problem.hasPrefix("Maximum nesting level reached") {
                let message = "nests deeper than \(maximumYAMLNesting) levels"
                return .failure(SuiteError(file: file, line: yamlLine(error), message: message))
            }
            return .failure(
                SuiteError(file: file, line: yamlLine(error), message: "is not valid YAML: \(yamlProblem(error))"))
        } catch {
            return .failure(SuiteError(file: file, message: "is not valid YAML"))
        }
        guard let root else {
            return .failure(SuiteError(file: file, message: "is empty; a suite needs `cases`"))
        }
        let reader = NodeReader(file: file)
        do {
            return .success(try reader.suite(root, defaultName: defaultName))
        } catch let error as SuiteError {
            return .failure(error)
        } catch {
            return .failure(SuiteError(file: file, message: "\(error)"))
        }
    }

    private static func yamlLine(_ error: YamlError) -> Int? {
        switch error {
        case .scanner(_, _, let mark, _), .parser(_, _, let mark, _), .composer(_, _, let mark, _):
            return mark.line
        default:
            return nil
        }
    }

    private static func yamlProblem(_ error: YamlError) -> String {
        switch error {
        case .scanner(_, let problem, _, _), .parser(_, let problem, _, _), .composer(_, let problem, _, _):
            return problem
        case .duplicatedKeysInMapping(let duplicates, _):
            return "duplicate keys \(duplicates.joined(separator: ", "))"
        default:
            return "\(error)"
        }
    }
}

/// Carries the result from the parsing thread back to the caller, which waits on a semaphore
/// until it is set.
private final class ResultBox: @unchecked Sendable {
    var result: Result<Suite, SuiteError>?
}
