import Foundation

/// Number and duration formatting shared by the reports. Locale-independent, so reports and
/// snapshots read the same on every machine.
public enum Format {
    /// `12`, `0.5`, `1.25`: no trailing zeros, at most three decimals.
    public static func number(_ value: Double) -> String {
        if value.rounded() == value, abs(value) < 1e15 {
            return String(Int64(value))
        }
        var text = String(format: "%.3f", locale: Locale(identifier: "en_US_POSIX"), value)
        while text.hasSuffix("0") { text.removeLast() }
        if text.hasSuffix(".") { text.removeLast() }
        return text
    }

    /// `850 ms` below a second, `1.24 s` from one second, `2 min 5 s` from a minute.
    public static func duration(_ seconds: Double) -> String {
        if seconds < 1 {
            return "\(Int((seconds * 1000).rounded())) ms"
        }
        if seconds < 60 {
            return String(format: "%.2f s", locale: Locale(identifier: "en_US_POSIX"), seconds)
        }
        let total = Int(seconds.rounded())
        return "\(total / 60) min \(total % 60) s"
    }

    /// `100%`, `67%`: whole percent, rounded half up.
    public static func percent(_ share: Double) -> String {
        "\(Int((share * 100).rounded()))%"
    }

    /// `+12%` / `-8%` / `±0%` change from `old` to `new`; nil when `old` is zero.
    public static func change(from old: Double, to new: Double) -> String? {
        guard old > 0 else { return nil }
        let percent = Int(((new - old) / old * 100).rounded())
        if percent == 0 { return "±0%" }
        return percent > 0 ? "+\(percent)%" : "\(percent)%"
    }
}
