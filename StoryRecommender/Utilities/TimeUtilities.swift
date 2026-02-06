import Foundation

enum TimeUtilities {
    static func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Sweet dreams"
        }
    }

    static func greetingEmoji() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "☀️"
        case 12..<17: return "🌤️"
        case 17..<21: return "🌅"
        default: return "🌙"
        }
    }

    static func isNightTime() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 19 || hour < 6
    }

    static func estimateReadingTime(wordCount: Int) -> Int {
        max(1, wordCount / Constants.wordsPerMinute)
    }

    static func estimateReadingTime(text: String) -> Int {
        let wordCount = text.split(separator: " ").count
        return estimateReadingTime(wordCount: wordCount)
    }
}
