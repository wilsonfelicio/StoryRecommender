import Foundation

final class CuratedStoryStore {
    static let shared = CuratedStoryStore()

    let stories: [Story]

    private init() {
        guard let url = Bundle.main.url(forResource: "curated-stories", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Story].self, from: data) else {
            stories = []
            return
        }
        stories = decoded
    }

    func search(preferences: StoryPreferences) -> [Story] {
        // First try exact match: mood AND at least one theme
        let exact = stories.filter { story in
            story.mood.contains(preferences.mood) &&
            !Set(story.themes).isDisjoint(with: Set(preferences.themes))
        }
        if !exact.isEmpty { return exact }

        // Relax: match mood OR at least one theme
        let relaxed = stories.filter { story in
            story.mood.contains(preferences.mood) ||
            !Set(story.themes).isDisjoint(with: Set(preferences.themes))
        }
        if !relaxed.isEmpty { return relaxed }

        // Fallback: return a random selection
        return Array(stories.shuffled().prefix(5))
    }

    func story(byId id: String) -> Story? {
        stories.first { $0.id == id }
    }
}
