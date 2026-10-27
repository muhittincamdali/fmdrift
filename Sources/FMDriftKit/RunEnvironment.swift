import Foundation

/// Where a run happened. The on-device model changes only with an OS update, so the OS version
/// and build identify the model a snapshot was recorded with.
public struct RunEnvironment: Sendable, Equatable, Codable {
    /// `macOS`.
    public var platform: String
    /// `27.0.1`.
    public var osVersion: String
    /// `26A434`.
    public var osBuild: String
    /// `Mac16,10`; empty when unknown.
    public var hardware: String
    /// `Apple M4`; empty when unknown.
    public var chip: String
    /// `en_US`.
    public var locale: String
    /// `system` for the on-device model, `replay` for recorded responses.
    public var provider: String
    /// `available`, or why the model is not: `appleIntelligenceNotEnabled`, `modelNotReady`, …
    public var modelAvailability: String
    /// The model's context window in tokens; nil when unknown.
    public var contextSize: Int?

    public init(
        platform: String,
        osVersion: String,
        osBuild: String,
        hardware: String = "",
        chip: String = "",
        locale: String = "",
        provider: String,
        modelAvailability: String,
        contextSize: Int? = nil
    ) {
        self.platform = platform
        self.osVersion = osVersion
        self.osBuild = osBuild
        self.hardware = hardware
        self.chip = chip
        self.locale = locale
        self.provider = provider
        self.modelAvailability = modelAvailability
        self.contextSize = contextSize
    }

    /// `macOS 27.0.1 (26A434)`.
    public var osLabel: String {
        osBuild.isEmpty ? "\(platform) \(osVersion)" : "\(platform) \(osVersion) (\(osBuild))"
    }

    /// `macOS-27.0.1-26A434`: the file name `record` uses, safe on every file system.
    public var snapshotName: String {
        let raw = [platform, osVersion, osBuild].filter { !$0.isEmpty }.joined(separator: "-")
        let allowed = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.")
        let name = String(raw.map { allowed.contains($0) ? $0 : "-" }.prefix(96))
        return name.isEmpty ? "unknown" : name
    }

    /// The OS this process runs on, with an empty provider and availability for the caller to
    /// fill in.
    public static func host(provider: String, modelAvailability: String, contextSize: Int?) -> RunEnvironment {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        var osVersion = "\(version.majorVersion).\(version.minorVersion)"
        if version.patchVersion > 0 { osVersion += ".\(version.patchVersion)" }
        return RunEnvironment(
            platform: "macOS",
            osVersion: osVersion,
            osBuild: sysctlString("kern.osversion") ?? "",
            hardware: sysctlString("hw.model") ?? "",
            chip: sysctlString("machdep.cpu.brand_string") ?? "",
            locale: Locale.current.identifier,
            provider: provider,
            modelAvailability: modelAvailability,
            contextSize: contextSize
        )
    }

    static func sysctlString(_ name: String) -> String? {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0, size < 4096 else { return nil }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else { return nil }
        let bytes = buffer.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
        let text = String(decoding: bytes, as: UTF8.self).trimmingCharacters(in: .whitespaces)
        return text.isEmpty ? nil : text
    }
}
