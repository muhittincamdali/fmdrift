import ArgumentParser
import FMDriftKit
import Foundation

/// A subcommand that runs with a ``Context`` and returns an exit status.
protocol ContextCommand: AsyncParsableCommand {
    func execute(_ context: Context) async -> Int32
}

/// The `fmdrift` command line.
public enum CLI {
    /// Parses `arguments` (without the program name), runs the command and returns its exit
    /// status. Help and version print to standard output and return 0; argument errors print to
    /// standard error and return 2.
    public static func main(arguments: [String], context: Context) async -> Int32 {
        if let word = arguments.first, let message = unknownCommandMessage(word, context: context) {
            context.error(message)
            return ExitStatus.usage
        }
        let command: any ParsableCommand
        do {
            command = try FMDriftCommand.parseAsRoot(arguments)
        } catch {
            let code = FMDriftCommand.exitCode(for: error)
            let message = FMDriftCommand.fullMessage(for: error)
            if code == .success {
                context.write(message + "\n")
                return ExitStatus.clean
            }
            context.writeError(message + "\n")
            return ExitStatus.usage
        }
        guard let runnable = command as? any ContextCommand else {
            // `--help`, `-h` and `help <subcommand>` parse to the library's help command, whose
            // own run() prints to standard output directly instead of through the context.
            context.write(helpMessage(for: arguments) + "\n")
            return ExitStatus.clean
        }
        return await runnable.execute(context)
    }

    /// `run` is the default subcommand, so `fmdrift frobnicate` used to look for a suite file
    /// named `frobnicate` and say it cannot be read. A first argument that names no subcommand,
    /// has neither `/` nor `.` the way a path to a suite would, and is not a file or folder is a
    /// mistyped command.
    static func unknownCommandMessage(_ word: String, context: Context) -> String? {
        let commands = FMDriftCommand.configuration.subcommands.map { $0._commandName }
        guard !word.isEmpty, !word.hasPrefix("-"), !word.contains("/"), !word.contains("."),
            !commands.contains(word), word != "help",
            !FileManager.default.fileExists(atPath: context.url(for: word).path)
        else { return nil }
        return "unknown command `\(word)`; the commands are \(commands.joined(separator: ", ")). "
            + "To run suites, give the path of a suite file or folder."
    }

    /// Help for the first subcommand named in `arguments`, or for fmdrift itself.
    static func helpMessage(for arguments: [String]) -> String {
        let subcommands = FMDriftCommand.configuration.subcommands
        for argument in arguments {
            if argument == "--" { break }
            if let subcommand = subcommands.first(where: { $0._commandName == argument }) {
                return FMDriftCommand.helpMessage(for: subcommand)
            }
        }
        return FMDriftCommand.helpMessage()
    }
}

struct FMDriftCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "fmdrift",
        abstract: "Snapshot and regression tests for prompts to Apple's on-device foundation model.",
        discussion: """
            The on-device model changes with OS updates. fmdrift runs your prompts from a YAML suite, checks every response, records the results per OS build and shows what changed between builds.

            Exit status: 0 when every case passed and nothing regressed, 1 when a case failed or regressed, 2 for wrong arguments, unreadable files or no model to run on.

            Documentation: https://muhittincamdali.github.io/fmdrift/
            """,
        version: FMDrift.version,
        subcommands: [
            RunCommand.self, RecordCommand.self, DiffCommand.self, ValidateCommand.self, InitCommand.self,
            DoctorCommand.self,
        ],
        defaultSubcommand: RunCommand.self
    )
}
