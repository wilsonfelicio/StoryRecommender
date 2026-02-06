import Foundation

@Observable
final class FavoritesViewModel {
    private(set) var favorites: [FavoriteEntry] = []
    private let storage = StorageService.shared

    init() {
        favorites = storage.loadFavorites()
    }

    var isEmpty: Bool { favorites.isEmpty }

    func isFavorite(storyId: String) -> Bool {
        favorites.contains { $0.storyId == storyId }
    }

    func toggleFavorite(story: Story) {
        if let index = favorites.firstIndex(where: { $0.storyId == story.id }) {
            favorites.remove(at: index)
        } else {
            let entry = FavoriteEntry(from: story)
            favorites.insert(entry, at: 0)
        }
        storage.saveFavorites(favorites)
    }

    func removeFavorite(storyId: String) {
        favorites.removeAll { $0.storyId == storyId }
        storage.saveFavorites(favorites)
    }
}
