import FMDriftCLI
import Foundation

let status = await CLI.main(arguments: Array(CommandLine.arguments.dropFirst()), context: .standard)
exit(status)
