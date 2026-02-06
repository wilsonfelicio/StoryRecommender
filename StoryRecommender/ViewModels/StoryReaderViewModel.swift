import Foundation

@Observable
final class StoryReaderViewModel {
    let storyId: String

    var story: Story?
    var isLoading = false
    var error: String?
    var fontSize: CGFloat = 18
    var scrollProgress: Double = 0

    // Narrator
    var speechService = SpeechService()
    var isNarratorPickerPresented = false
    var selectedNarrator: NarratorCharacter?
    var isNarrating: Bool {
        speechService.playbackState != .idle
    }

    private let storage = StorageService.shared

    init(storyId: String) {
        self.storyId = storyId
    }

    deinit {
        speechService.stop()
    }

    func loadStory() {
        // Try to find story from all sources
        if let found = storage.allStory(byId: storyId) {
            // If Gutenberg story with no content, fetch full text
            if found.source == .gutenberg && found.content.isEmpty {
                Task { await fetchGutenbergText(story: found) }
            } else {
                self.story = found
            }
            return
        }
        error = "Story not found"
    }

    @MainActor
    private func fetchGutenbergText(story: Story) async {
        isLoading = true
        // Extract numeric book ID from "gut-123"
        let bookIdStr = String(story.id.dropFirst(4))
        guard let bookId = Int(bookIdStr) else {
            error = "Invalid book ID"
            isLoading = false
            return
        }

        do {
            let fullText = try await GutenbergService.shared.fetchFullText(bookId: bookId)
            // Truncate to reasonable length for reading
            let truncated = TextCleaner.truncate(fullText, toWords: 3000)
            let readingTime = TimeUtilities.estimateReadingTime(text: truncated)

            let fullStory = Story(
                id: story.id,
                title: story.title,
                author: story.author,
                source: .gutenberg,
                content: truncated,
                summary: story.summary,
                length: story.length,
                mood: story.mood,
                themes: story.themes,
                readingTimeMinutes: readingTime,
                coverEmoji: story.coverEmoji
            )
            self.story = fullStory
            storage.cacheGutenbergStory(fullStory)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func increaseFontSize() {
        if fontSize < 28 { fontSize += 2 }
    }

    func decreaseFontSize() {
        if fontSize > 12 { fontSize -= 2 }
    }

    // MARK: - Narration

    func startNarration(character: NarratorCharacter) {
        guard let story = story else { return }
        selectedNarrator = character
        speechService.startReading(text: story.content, character: character)
    }

    func stopNarration() {
        speechService.stop()
        selectedNarrator = nil
    }

    func toggleNarrationPlayPause() {
        speechService.togglePlayPause()
    }

    func showNarratorPicker() {
        isNarratorPickerPresented = true
    }
}
