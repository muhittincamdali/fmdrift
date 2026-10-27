import Foundation

/// Makes model output and suite text safe to print in each report format.
///
/// Model output is untrusted: it can hold terminal escape sequences, bidirectional overrides
/// that reorder what a reviewer sees, or markup. Each format escapes what would be interpreted.
public enum TextSafety {
    /// Replaces control characters (C0 except tab, C1, DEL), bidirectional controls and
    /// zero-width characters with a visible `\u{…}` escape. Newlines become a space; reports show
    /// one line per entry.
    public static func terminal(_ text: String) -> String {
        var output = ""
        output.unicodeScalars.reserveCapacity(text.unicodeScalars.count)
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 0x0A, 0x0D: output.unicodeScalars.append(" ")
            case 0x09: output.unicodeScalars.append(scalar)
            default:
                if isHidden(scalar) {
                    output += "\\u{\(String(scalar.value, radix: 16, uppercase: true))}"
                } else {
                    output.unicodeScalars.append(scalar)
                }
            }
        }
        return output
    }

    static func isHidden(_ scalar: Unicode.Scalar) -> Bool {
        switch scalar.value {
        case 0x00...0x1F, 0x7F...0x9F: return true
        // Bidirectional embeddings, overrides and isolates; Arabic letter mark.
        case 0x202A...0x202E, 0x2066...0x2069, 0x061C: return true
        // Zero-width space, joiners, LRM/RLM, word joiner, BOM.
        case 0x200B...0x200F, 0x2060, 0xFEFF: return true
        default: return false
        }
    }

    /// Text for a Markdown table cell or paragraph: hidden characters escaped as in the
    /// terminal, HTML and Markdown syntax neutralised, pipes escaped.
    public static func markdown(_ text: String) -> String {
        var output = ""
        for character in terminal(text) {
            switch character {
            case "&": output += "&amp;"
            case "<": output += "&lt;"
            case ">": output += "&gt;"
            case "|": output += "\\|"
            case "\\", "`", "*", "_", "[", "]", "#", "~", "!": output += "\\\(character)"
            default: output.append(character)
            }
        }
        return output
    }

    /// Text for XML attributes and character data. Characters XML 1.0 does not allow are
    /// escaped as in the terminal.
    public static func xml(_ text: String) -> String {
        var output = ""
        for scalar in text.unicodeScalars {
            switch scalar {
            case "&": output += "&amp;"
            case "<": output += "&lt;"
            case ">": output += "&gt;"
            case "\"": output += "&quot;"
            case "'": output += "&apos;"
            case "\n": output += "&#10;"
            case "\r": output += "&#13;"
            case "\t": output += "&#9;"
            default:
                if isHidden(scalar) || scalar.value == 0xFFFE || scalar.value == 0xFFFF {
                    output += "\\u{\(String(scalar.value, radix: 16, uppercase: true))}"
                } else {
                    output.unicodeScalars.append(scalar)
                }
            }
        }
        return output
    }
}
