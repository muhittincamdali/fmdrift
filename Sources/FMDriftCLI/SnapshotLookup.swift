import FMDriftKit
import Foundation

/// Finds the snapshot for a suite from a `--baseline` or `--replay` path.
enum SnapshotLookup {
    enum Outcome {
        case found(URL, RunResult)
        /// The folder has no snapshot of this suite.
        case missing
        /// An error was reported.
        case failed
    }

    /// - Parameters:
    ///   - path: A snapshot file (only with a single suite) or a folder written by `record`.
    ///   - avoiding: In a folder, prefer the newest snapshot from another OS build than this one.
    static func find(
        at path: String,
        suite: String,
        suiteCount: Int,
        avoiding environment: RunEnvironment?,
        context: Context
    ) -> Outcome {
        let url = context.url(for: path)
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            context.error("\(path) does not exist")
            return .failed
        }
        guard isDirectory.boolValue else {
            guard suiteCount == 1 else {
                context.error(
                    "\(path) is one snapshot, but \(suiteCount) suites are running; pass the snapshot folder instead")
                return .failed
            }
            do {
                let result = try SnapshotStore.read(contentsOf: url)
                if result.suite != suite {
                    context.notice("\(context.display(url)) was recorded for suite `\(result.suite)`, not `\(suite)`")
                }
                return .found(url, result)
            } catch {
                context.error("\(context.display(url)): \(error.message)")
                return .failed
            }
        }

        let folder = url.appendingPathComponent(suite, isDirectory: true)
        let files =
            ((try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? [])
            .filter { $0.pathExtension == "json" }
        var snapshots: [(URL, RunResult)] = []
        for file in files {
            do {
                snapshots.append((file, try SnapshotStore.read(contentsOf: file)))
            } catch {
                context.notice("skipping \(context.display(file)): \(error.message)")
            }
        }
        // Newest first; the file name breaks ties so the choice never depends on directory order.
        snapshots.sort {
            $0.1.recordedAt != $1.1.recordedAt
                ? $0.1.recordedAt > $1.1.recordedAt : $0.0.lastPathComponent < $1.0.lastPathComponent
        }
        if let environment,
            let other = snapshots.first(where: { $0.1.environment.snapshotName != environment.snapshotName })
        {
            return .found(other.0, other.1)
        }
        if let newest = snapshots.first { return .found(newest.0, newest.1) }
        return .missing
    }
}
