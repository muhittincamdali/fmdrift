import Foundation

/// Reads and writes snapshot files: a ``RunResult`` as pretty-printed JSON with sorted keys, so
/// that a snapshot committed to git shows readable diffs.
public enum SnapshotStore {
    /// Larger files are refused before decoding.
    public static let maximumSize = 32 * 1024 * 1024

    /// `<directory>/<suite>/<platform>-<version>-<build>.json`.
    public static func url(in directory: URL, suite: String, environment: RunEnvironment) -> URL {
        directory
            .appendingPathComponent(NodeReader.sanitizedName(suite), isDirectory: true)
            .appendingPathComponent(environment.snapshotName + ".json")
    }

    public static func encode(_ result: RunResult) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        // Encoding plain value types cannot fail.
        var data = (try? encoder.encode(result)) ?? Data()
        data.append(0x0A)
        return data
    }

    public static func write(_ result: RunResult, to url: URL) throws(SnapshotError) {
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
        do {
            return try decoder.decode(RunResult.self, from: data)
        } catch {
            throw SnapshotError(path: path, message: "is not a valid snapshot (\(describe(error)))")
        }
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
