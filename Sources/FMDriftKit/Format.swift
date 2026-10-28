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

    /// `850 ms` below a second, `1.24 s` from one second, `2 min 5 s` from a minute. `–` for a
    /// value that is not a duration (negative, infinite or NaN).
    public static func duration(_ seconds: Double) -> String {
        // Snapshots and suites are untrusted; converting 1e300 to Int would trap.
        guard seconds.isFinite, seconds >= 0 else { return "–" }
        if seconds < 1 {
            return "\(Int((seconds * 1000).rounded())) ms"
        }
        if seconds < 60 {
            return String(format: "%.2f s", locale: Locale(identifier: "en_US_POSIX"), seconds)
        }
        let total = seconds.rounded()
        let minutes = (total / 60).rounded(.down)
        return "\(number(minutes)) min \(number(total - minutes * 60)) s"
    }

    /// `1 case`, `0 cases`, `2 cases`.
    public static func count(_ value: Int, _ singular: String, _ plural: String) -> String {
        value == 1 ? "1 \(singular)" : "\(value) \(plural)"
    }

    /// `100%`, `67%`: whole percent, rounded half up.
    public static func percent(_ share: Double) -> String {
        "\(number((share * 100).rounded()))%"
    }

    /// Changes beyond this many percent read as `>+999999%`, so that a tiny baseline latency
    /// does not print a 300-digit number.
    static let largestChange = 999_999.0

    /// `+12%` / `-8%` / `±0%` change from `old` to `new`; nil when `old` is zero or either
    /// value is not finite.
    public static func change(from old: Double, to new: Double) -> String? {
        guard old > 0, old.isFinite, new.isFinite else { return nil }
        let percent = ((new - old) / old * 100).rounded()
        if percent > largestChange { return ">+\(number(largestChange))%" }
        if percent < -largestChange { return "<-\(number(largestChange))%" }
        if percent == 0 { return "±0%" }
        return percent > 0 ? "+\(number(percent))%" : "\(number(percent))%"
    }
}
