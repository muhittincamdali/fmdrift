import CryptoKit
import Foundation

/// Reads and writes snapshot files: a ``RunResult`` as pretty-printed JSON with sorted keys, so
/// that a snapshot committed to git shows readable diffs.
public enum SnapshotStore {
    /// Larger files are refused before decoding.
    public static let maximumSize = 32 * 1024 * 1024

    /// `<directory>/<suite folder>/<platform>-<version>-<build>.json`.
    public static func url(in directory: URL, suite: String, environment: RunEnvironment) -> URL {
        folder(in: directory, suite: suite).appendingPathComponent(environment.snapshotName + ".json")
    }

    /// The folder that holds a suite's snapshots.
    ///
    /// A name that suite files allow (1–64 letters, digits, `-`, `_` or `.`, not starting with
    /// `.`) is the folder name as it is. Any other name, which only the API can pass, has the
    /// other characters replaced by `-` and gets `-` and 12 hex digits of its SHA-256 appended,
    /// so that `a/b` and `a?b` do not share a folder.
    public static func folder(in directory: URL, suite: String) -> URL {
        directory.appendingPathComponent(folderName(suite), isDirectory: true)
    }

    static func folderName(_ suite: String) -> String {
        let sanitized = NodeReader.sanitizedName(suite)
        guard sanitized != suite else { return suite }
        let digest = SHA256.hash(data: Data(suite.utf8)).prefix(6)
        return sanitized + "-" + digest.map { String(format: "%02x", $0) }.joined()
    }

    public static func encode(_ result: RunResult) -> Data {
        var data = JSONOutput.data(result)
        data.append(0x0A)
        return data
    }

    /// Replaces a snapshot of the same suite, but refuses to replace one of another suite: names
    /// that differ only in case share a folder on a case-insensitive disk, the default on macOS.
    public static func write(_ result: RunResult, to url: URL) throws(SnapshotError) {
        if let existing = try? read(contentsOf: url), existing.suite != result.suite {
            throw SnapshotError(
                path: url.path,
                message:
                    "holds a snapshot of suite `\(Excerpt.of(existing.suite))`, not `\(Excerpt.of(result.suite))`; give each suite a name that differs in more than case"
            )
        }
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try encode(result).write(to: url, options: .atomic)
        } catch {
            throw SnapshotError(path: url.path, message: "cannot be written (\(error.localizedDescription))")
        }
    }

    public static func read(contentsOf url: URL) throws(SnapshotError) -> RunResult {
        let path = url.path
        let data: Data
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            if let size = attributes[.size] as? Int, size > maximumSize {
                throw SnapshotError(path: path, message: "is larger than \(maximumSize) bytes")
            }
            data = try Data(contentsOf: url)
        } catch let error as SnapshotError {
            throw error
        } catch {
            throw SnapshotError(path: path, message: "cannot be read (\(error.localizedDescription))")
        }
        return try decode(data, path: path)
    }

    public static func decode(_ data: Data, path: String) throws(SnapshotError) -> RunResult {
        guard data.count <= maximumSize else {
            throw SnapshotError(path: path, message: "is larger than \(maximumSize) bytes")
        }
        guard JSONValue.nestingDepth(of: data) <= JSONValue.maximumDepth else {
            throw SnapshotError(path: path, message: "nests deeper than \(JSONValue.maximumDepth) levels")
        }
        struct Header: Decodable { var format: Int? }
        guard let header = try? JSONDecoder().decode(Header.self, from: data) else {
            throw SnapshotError(path: path, message: "is not a JSON object; is it an fmdrift snapshot?")
        }
        guard let format = header.format else {
            throw SnapshotError(path: path, message: "has no `format`; is it an fmdrift snapshot?")
        }
        guard format <= RunResult.currentFormat else {
            throw SnapshotError(
                path: path,
                message:
                    "uses snapshot format \(format); this fmdrift reads format \(RunResult.currentFormat). Update fmdrift."
            )
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let result: RunResult
        do {
            result = try decoder.decode(RunResult.self, from: data)
        } catch {
            throw SnapshotError(path: path, message: "is not a valid snapshot (\(describe(error)))")
        }
        if let problem = repeatedCaseID(in: result) {
            throw SnapshotError(path: path, message: "is not a valid snapshot (\(problem))")
        }
        return result
    }

    /// Cases are matched by id. A snapshot that repeats an id, such as a file written twice into
    /// one, would be compared case by case against the wrong entries; suites refuse it too.
    private static func repeatedCaseID(in result: RunResult) -> String? {
        var firstIndex: [String: Int] = [:]
        for (index, testCase) in result.cases.enumerated() {
            if let first = firstIndex[testCase.id] {
                return "case id `\(Excerpt.of(testCase.id))` at $.cases[\(index)] is already used at $.cases[\(first)]"
            }
            firstIndex[testCase.id] = index
        }
        return nil
    }

    private static func describe(_ error: any Error) -> String {
        guard let error = error as? DecodingError else { return "\(error)" }
        func location(_ path: [any CodingKey]) -> String {
            guard !path.isEmpty else { return "the top level" }
            return "$" + path.map { $0.intValue.map { "[\($0)]" } ?? ".\($0.stringValue)" }.joined()
        }
        switch error {
        case .keyNotFound(let key, let context):
            return "missing `\(key.stringValue)` at \(location(context.codingPath))"
        case .typeMismatch(_, let context), .valueNotFound(_, let context), .dataCorrupted(let context):
            return "unexpected value at \(location(context.codingPath))"
        @unknown default:
            return "\(error)"
        }
    }
}

/// A snapshot file that cannot be read or written.
public struct SnapshotError: Error, Equatable, CustomStringConvertible {
    public var path: String
    public var message: String

    public var description: String { "\(path): \(message)" }
}
