import Foundation

@Observable
final class HistoryViewModel {
    private(set) var entries: [HistoryEntry] = []
    private let storage = StorageService.shared

    init() {
        entries = storage.loadHistory()
    }

    var isEmpty: Bool { entries.isEmpty }

    func recordReading(story: Story) {
        // Update existing or add new
        if let index = entries.firstIndex(where: { $0.storyId == story.id }) {
            entries[index].lastReadAt = Date()
            // Move to front
            let entry = entries.remove(at: index)
            entries.insert(entry, at: 0)
        } else {
            let entry = HistoryEntry(from: story)
            entries.insert(entry, at: 0)
        }
        // Trim to max
        if entries.count > Constants.maxHistoryEntries {
            entries = Array(entries.prefix(Constants.maxHistoryEntries))
        }
        storage.saveHistory(entries)
    }

    func updateScrollPosition(storyId: String, position: Double) {
        if let index = entries.firstIndex(where: { $0.storyId == storyId }) {
            entries[index].scrollPosition = position
            storage.saveHistory(entries)
        }
    }

    func clearHistory() {
        entries.removeAll()
        storage.saveHistory(entries)
    }
}
