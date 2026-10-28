import Foundation

/// Makes model output and suite text safe to print in each report format.
///
/// Model output is untrusted: it can hold terminal escape sequences, bidirectional overrides
/// that reorder what a reviewer sees, or markup. Each format escapes what would be interpreted.
public enum TextSafety {
    /// Replaces control characters (C0 except tab, C1, DEL), bidirectional controls, zero-width
    /// and other invisible characters, line separators and tag characters with a visible
    /// `\u{…}` escape. Newlines become a space; reports show one line per entry.
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
        // Line and paragraph separators, which some log viewers break lines at.
        case 0x2028, 0x2029: return true
        // Soft hyphen, Mongolian vowel separator, invisible operators (function application,
        // times, separator, plus), deprecated format characters, interlinear annotations.
        case 0x00AD, 0x180E, 0x2061...0x2064, 0x206A...0x206F, 0xFFF9...0xFFFB: return true
        // Tag characters can spell out hidden text. Emoji subdivision flags use them too, and
        // show escaped: visible beats invisible here.
        case 0xE0000...0xE007F: return true
        default: return false
        }
    }

    /// Text for a Markdown table cell or paragraph: hidden characters escaped as in the
    /// terminal, HTML and Markdown syntax neutralised, pipes escaped.
    ///
    /// A report is often posted as a pull request comment, where GitHub turns `@name` into a
    /// mention that notifies that account, `#12` and `GH-12` (in any case) into links that show up
    /// on issue 12, and bare `https://…` and `www.…` addresses into links. A backslash does not
    /// stop mentions and issue links, which GitHub finds in the rendered text, so `@`, `#` and
    /// the `-` of `GH-` before a digit are followed by a zero-width space (`&#8203;`). The `:` of
    /// `://` and the `.` after `www` are backslash-escaped, which shows the same text without a
    /// link.
    public static func markdown(_ text: String) -> String {
        var output = ""
        let characters = Array(terminal(text))
        for (index, character) in characters.enumerated() {
            switch character {
            case "&": output += "&amp;"
            case "<": output += "&lt;"
            case ">": output += "&gt;"
            case "|": output += "\\|"
            case "@", "#": output += "\(character)&#8203;"
            case "-" where isIssueReference(characters, hyphenAt: index):
                output += "-&#8203;"
            case "\\", "`", "*", "_", "[", "]", "~", "!": output += "\\\(character)"
            case ":" where characters[(index + 1)...].starts(with: "//"):
                output += "\\:"
            case "." where index >= 3 && String(characters[(index - 3)..<index]).lowercased() == "www":
                output += "\\."
            default: output.append(character)
            }
        }
        return output
    }

    /// Whether the `-` at `index` is the hyphen of `GH-` followed by a digit, which GitHub links
    /// to an issue or pull request.
    private static func isIssueReference(_ characters: [Character], hyphenAt index: Int) -> Bool {
        guard index >= 2, index + 1 < characters.count, characters[index + 1].isASCII,
            characters[index + 1].isNumber
        else { return false }
        return String(characters[(index - 2)..<index]).lowercased() == "gh"
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
