import Foundation

enum TextCleaner {
    /// Remove Project Gutenberg headers, footers, and clean up text
    static func clean(_ text: String) -> String {
        var result = text

        // Remove Gutenberg header (everything before "*** START OF")
        if let startRange = result.range(of: "*** START OF", options: .caseInsensitive) {
            // Find end of that line
            if let lineEnd = result[startRange.upperBound...].firstIndex(of: "\n") {
                result = String(result[result.index(after: lineEnd)...])
            }
        }

        // Remove Gutenberg footer (everything after "*** END OF")
        if let endRange = result.range(of: "*** END OF", options: .caseInsensitive) {
            result = String(result[..<endRange.lowerBound])
        }

        // Remove "Produced by" lines
        let lines = result.components(separatedBy: "\n")
        let filtered = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.hasPrefix("Produced by") && !trimmed.hasPrefix("Updated editions")
        }
        result = filtered.joined(separator: "\n")

        // Normalize whitespace: collapse 3+ newlines into 2
        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Truncate text to approximate word count
    static func truncate(_ text: String, toWords maxWords: Int) -> String {
        let words = text.split(separator: " ")
        if words.count <= maxWords { return text }

        let truncated = words.prefix(maxWords).joined(separator: " ")
        // Try to end at a sentence boundary
        if let lastPeriod = truncated.lastIndex(of: ".") {
            return String(truncated[...lastPeriod])
        }
        return truncated + "..."
    }
}
