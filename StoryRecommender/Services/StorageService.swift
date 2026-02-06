import Foundation

@Observable
final class StorageService {
    static let shared = StorageService()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let preferences = "story_preferences"
        static let favorites = "story_favorites"
        static let history = "story_history"
        static let darkModeOverride = "dark_mode_override"
    }

    // MARK: - Preferences

    func loadPreferences() -> StoryPreferences {
        guard let data = defaults.data(forKey: Keys.preferences),
              let prefs = try? JSONDecoder().decode(StoryPreferences.self, from: data) else {
            return .default
        }
        return prefs
    }

    func savePreferences(_ prefs: StoryPreferences) {
        if let data = try? JSONEncoder().encode(prefs) {
            defaults.set(data, forKey: Keys.preferences)
        }
    }

    // MARK: - Favorites

    func loadFavorites() -> [FavoriteEntry] {
        guard let data = defaults.data(forKey: Keys.favorites),
              let entries = try? JSONDecoder().decode([FavoriteEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func saveFavorites(_ entries: [FavoriteEntry]) {
        let trimmed = Array(entries.prefix(Constants.maxFavorites))
        if let data = try? JSONEncoder().encode(trimmed) {
            defaults.set(data, forKey: Keys.favorites)
        }
    }

    // MARK: - History

    func loadHistory() -> [HistoryEntry] {
        guard let data = defaults.data(forKey: Keys.history),
              let entries = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func saveHistory(_ entries: [HistoryEntry]) {
        let trimmed = Array(entries.prefix(Constants.maxHistoryEntries))
        if let data = try? JSONEncoder().encode(trimmed) {
            defaults.set(data, forKey: Keys.history)
        }
    }

    // MARK: - Dark Mode

    /// nil = auto, true = forced dark, false = forced light
    var darkModeOverride: Bool? {
        get {
            guard defaults.object(forKey: Keys.darkModeOverride) != nil else { return nil }
            return defaults.bool(forKey: Keys.darkModeOverride)
        }
        set {
            if let value = newValue {
                defaults.set(value, forKey: Keys.darkModeOverride)
            } else {
                defaults.removeObject(forKey: Keys.darkModeOverride)
            }
        }
    }

    // MARK: - Generated Stories (File-based)

    private var generatedStoriesURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("generated-stories.json")
    }

    func loadGeneratedStories() -> [Story] {
        guard let data = try? Data(contentsOf: generatedStoriesURL),
              let stories = try? JSONDecoder().decode([Story].self, from: data) else {
            return []
        }
        return stories
    }

    func saveGeneratedStory(_ story: Story) {
        var stories = loadGeneratedStories()
        stories.insert(story, at: 0)
        if let data = try? JSONEncoder().encode(stories) {
            try? data.write(to: generatedStoriesURL, options: .atomic)
        }
    }

    func generatedStory(byId id: String) -> Story? {
        loadGeneratedStories().first { $0.id == id }
    }

    func allStory(byId id: String) -> Story? {
        // Check curated first, then generated, then gutenberg cache
        if let story = CuratedStoryStore.shared.story(byId: id) {
            return story
        }
        if let story = generatedStory(byId: id) {
            return story
        }
        if let story = loadGutenbergCache(id: id) {
            return story
        }
        return nil
    }

    // MARK: - Gutenberg Story Cache (File-based)

    private var gutenbergCacheURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("gutenberg-cache.json")
    }

    func loadGutenbergCache() -> [Story] {
        guard let data = try? Data(contentsOf: gutenbergCacheURL),
              let stories = try? JSONDecoder().decode([Story].self, from: data) else {
            return []
        }
        return stories
    }

    func loadGutenbergCache(id: String) -> Story? {
        loadGutenbergCache().first { $0.id == id }
    }

    func cacheGutenbergStory(_ story: Story) {
        var stories = loadGutenbergCache()
        if !stories.contains(where: { $0.id == story.id }) {
            stories.append(story)
            // Keep cache reasonable
            if stories.count > 50 {
                stories = Array(stories.suffix(50))
            }
            if let data = try? JSONEncoder().encode(stories) {
                try? data.write(to: gutenbergCacheURL, options: .atomic)
            }
        }
    }
}
