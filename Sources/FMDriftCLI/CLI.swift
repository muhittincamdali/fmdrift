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
