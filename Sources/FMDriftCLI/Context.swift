import FMDriftKit
import Foundation

/// Exit statuses. CI reads them, so they never change meaning.
public enum ExitStatus {
    /// Every case passed and nothing regressed.
    public static let clean: Int32 = 0
    /// A case failed, a snapshot diff found a regression, or a suite is invalid (`validate`).
    public static let findings: Int32 = 1
    /// Wrong arguments, an unreadable suite or snapshot, or no model to run on.
    public static let usage: Int32 = 2
}

/// Everything a command touches outside its arguments, so tests can run commands in-process.
public struct Context: Sendable {
    public var write: @Sendable (String) -> Void
    public var writeError: @Sendable (String) -> Void
    public var currentDirectory: URL
    public var environment: [String: String]
    /// Standard error is a terminal: show progress there.
    public var showsProgress: Bool
    public var style: TerminalStyle
    /// The on-device model, or a stand-in in tests. The argument is the timeout in seconds.
    public var makeProvider: @Sendable (Double) -> any ModelProvider

    public init(
        write: @escaping @Sendable (String) -> Void,
        writeError: @escaping @Sendable (String) -> Void,
        currentDirectory: URL,
        environment: [String: String],
        showsProgress: Bool,
        style: TerminalStyle,
        makeProvider: @escaping @Sendable (Double) -> any ModelProvider
    ) {
        self.write = write
        self.writeError = writeError
        self.currentDirectory = currentDirectory
        self.environment = environment
        self.showsProgress = showsProgress
        self.style = style
        self.makeProvider = makeProvider
    }

    /// The real terminal, file system and model.
    public static var standard: Context {
        let environment = ProcessInfo.processInfo.environment
        return Context(
            write: { text in FileHandle.standardOutput.write(Data(text.utf8)) },
            writeError: { text in FileHandle.standardError.write(Data(text.utf8)) },
            currentDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true),
            environment: environment,
            showsProgress: isatty(STDERR_FILENO) == 1 && environment["CI"] == nil,
            style: .detect(environment: environment),
            makeProvider: { timeout in SystemModelProvider(timeout: timeout) }
        )
    }

    /// Resolves a path given on the command line against the current directory.
    func url(for path: String) -> URL {
        let expanded = (path as NSString).expandingTildeInPath
        if expanded.hasPrefix("/") { return URL(fileURLWithPath: expanded).standardizedFileURL }
        return currentDirectory.appendingPathComponent(expanded).standardizedFileURL
    }

    /// Path relative to the current directory when it is inside it, for messages.
    func display(_ url: URL) -> String {
        let base = currentDirectory.standardizedFileURL.path
        let path = url.standardizedFileURL.path
        if path.hasPrefix(base + "/") { return String(path.dropFirst(base.count + 1)) }
        return path
    }

    func error(_ message: String) {
        writeError(style.red("error: ") + message + "\n")
    }

    func notice(_ message: String) {
        writeError(style.yellow("note: ") + message + "\n")
    }

    /// Writes a report file; returns false (after saying why) when it cannot.
    func writeFile(_ text: String, to path: String) -> Bool {
        let url = url(for: path)
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try Data(text.utf8).write(to: url, options: .atomic)
            return true
        } catch {
            self.error("cannot write \(path): \(error.localizedDescription)")
            return false
        }
    }
}
