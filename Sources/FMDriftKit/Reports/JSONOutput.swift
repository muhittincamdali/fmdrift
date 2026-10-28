import Foundation

/// JSON as fmdrift writes it: snapshots, `--json` output and `doctor --json`. Pretty-printed with
/// sorted keys, so committed snapshots show readable diffs.
///
/// JSONEncoder escapes C0 control characters but writes the rest of a string as it is. The JSON
/// stays valid, yet `jq -r` prints a model's U+009B (a one-byte CSI), U+202E or U+2028 straight
/// to the terminal. Every character ``TextSafety`` hides in reports is written as a `\u` escape
/// instead; parsers read back the same text.
public enum JSONOutput {
    public static func data(_ value: some Encodable) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        // Encoding plain value types cannot fail.
        let data = (try? encoder.encode(value)) ?? Data()
        return Data(escapingHiddenCharacters(String(decoding: data, as: UTF8.self)).utf8)
    }

    public static func text(_ value: some Encodable) -> String {
        String(decoding: data(value), as: UTF8.self) + "\n"
    }

    /// Outside strings, encoded JSON holds only ASCII, so every character from U+007F on is
    /// inside a string and can be replaced by its escape.
    static func escapingHiddenCharacters(_ json: String) -> String {
        func needsEscape(_ scalar: Unicode.Scalar) -> Bool {
            scalar.value >= 0x7F && TextSafety.isHidden(scalar)
        }
        guard json.unicodeScalars.contains(where: needsEscape) else { return json }
        var output = ""
        output.unicodeScalars.reserveCapacity(json.unicodeScalars.count)
        for scalar in json.unicodeScalars {
            guard needsEscape(scalar) else {
                output.unicodeScalars.append(scalar)
                continue
            }
            // UTF-16 code units in lowercase hex, as JSONEncoder writes control characters;
            // characters above U+FFFF become a surrogate pair.
            for unit in String(scalar).utf16 {
                let hex = String(unit, radix: 16)
                output += "\\u" + String(repeating: "0", count: 4 - hex.count) + hex
            }
        }
        return output
    }
}
