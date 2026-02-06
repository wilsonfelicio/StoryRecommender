import Foundation

enum RelativeDateFormatter {
    private static let formatter: Foundation.RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f
    }()

    static func string(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 {
            return "Just now"
        }
        return formatter.localizedString(for: date, relativeTo: now)
    }
}
