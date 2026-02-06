import Foundation

@Observable
final class ResultsViewModel {
    let preferences: StoryPreferences

    var curatedStories: [Story] = []
    var gutenbergStories: [Story] = []
    var isLoadingGutenberg = false
    var gutenbergError: String?

    init(preferences: StoryPreferences) {
        self.preferences = preferences
    }

    func loadStories() {
        // Curated: instant
        curatedStories = CuratedStoryStore.shared.search(preferences: preferences)

        // Gutenberg: async
        Task {
            await loadGutenberg()
        }
    }

    @MainActor
    private func loadGutenberg() async {
        isLoadingGutenberg = true
        gutenbergError = nil
        do {
            gutenbergStories = try await GutenbergService.shared.search(
                themes: preferences.themes,
                mood: preferences.mood
            )
        } catch {
            gutenbergError = error.localizedDescription
        }
        isLoadingGutenberg = false
    }
}
