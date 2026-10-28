import FMDriftKit
import Foundation

/// Finds suite files from the command line, or in the current directory.
enum SuiteDiscovery {
    static let extensions: Set<String> = ["yaml", "yml", "json"]
    /// Looked for in the current directory when no suite is given.
    static let defaultFiles = ["fmdrift.yaml", "fmdrift.yml"]
    static let defaultDirectory = "fmdrift"

    struct NoSuites: Error {}

    /// Files to read: each argument as a file, or the suite files directly inside a directory.
    static func files(_ arguments: [String], context: Context) throws(NoSuites) -> [URL] {
        let fileManager = FileManager.default
        if arguments.isEmpty {
            for name in defaultFiles {
                let url = context.currentDirectory.appendingPathComponent(name)
                if fileManager.fileExists(atPath: url.path) { return [url] }
            }
            let directory = context.currentDirectory.appendingPathComponent(defaultDirectory, isDirectory: true)
            let found = suites(in: directory)
            if found.isEmpty { throw NoSuites() }
            return found
        }
        var urls: [URL] = []
        for argument in arguments {
            let url = context.url(for: argument)
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                urls.append(contentsOf: suites(in: url))
            } else {
                urls.append(url)
            }
        }
        if urls.isEmpty { throw NoSuites() }
        return urls
    }

    static func suites(in directory: URL) -> [URL] {
        let contents =
            (try? FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )) ?? []
        return
            contents
            .filter { extensions.contains($0.pathExtension.lowercased()) }
            .filter { (try? $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    static let noSuiteMessage =
        "no suite found: pass a suite file, or create fmdrift.yaml with `fmdrift init`"

    /// Reads every suite; reports each unreadable one and returns nil if any failed.
    static func load(_ urls: [URL], context: Context) -> [(url: URL, suite: Suite)]? {
        var loaded: [(URL, Suite)] = []
        var failed = false
        for url in urls {
            do {
                loaded.append((url, try SuiteLoader.load(contentsOf: url)))
            } catch {
                context.error(
                    "\(context.display(url.deletingLastPathComponent().appendingPathComponent(error.file)))\(error.line.map { ":\($0)" } ?? ""): \(error.message)"
                )
                failed = true
            }
        }
        if failed { return nil }
        // Keyed by the lowercased name: macOS disks ignore case, so `Support` and `support` would
        // share a snapshot folder.
        var names: [String: (url: URL, name: String)] = [:]
        for (url, suite) in loaded {
            let key = suite.name.lowercased()
            if let other = names[key] {
                let naming =
                    other.name == suite.name
                    ? "are both named `\(suite.name)`"
                    : "are named `\(suite.name)` and `\(other.name)`, which differ only in case"
                context.error(
                    "\(context.display(url)) and \(context.display(other.url)) \(naming); snapshots are stored by suite name, so give each its own `name`"
                )
                return nil
            }
            names[key] = (url, suite.name)
        }
        return loaded
    }
}
