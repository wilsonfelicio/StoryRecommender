import Foundation

@Observable
final class HomeViewModel {
    var preferences: StoryPreferences
    var searchText = ""
    private(set) var searchResults: [Story] = []
    private let storage = StorageService.shared

    init() {
        preferences = storage.loadPreferences()
    }

    var greeting: String {
        TimeUtilities.greeting()
    }

    var greetingEmoji: String {
        TimeUtilities.greetingEmoji()
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        let curated = CuratedStoryStore.shared.stories
        let generated = storage.loadGeneratedStories()
        let gutenberg = storage.loadGutenbergCache()

        let all = curated + generated + gutenberg

        searchResults = all.filter { story in
            story.title.lowercased().contains(query) ||
            story.author.lowercased().contains(query) ||
            story.themes.contains { $0.rawValue.lowercased().contains(query) } ||
            story.mood.contains { $0.rawValue.lowercased().contains(query) } ||
            story.summary.lowercased().contains(query)
        }
    }

    func savePreferences() {
        storage.savePreferences(preferences)
    }

    func toggleTheme(_ theme: StoryTheme) {
        if let index = preferences.themes.firstIndex(of: theme) {
            preferences.themes.remove(at: index)
        } else {
            preferences.themes.append(theme)
        }
        savePreferences()
    }

    func setMood(_ mood: StoryMood) {
        preferences.mood = mood
        savePreferences()
    }

    func setLength(_ length: StoryLength) {
        preferences.length = length
        savePreferences()
    }
}
