import SwiftUI

struct FavoriteButton: View {
    let story: Story
    @Environment(FavoritesViewModel.self) private var favoritesVM

    var body: some View {
        let isFav = favoritesVM.isFavorite(storyId: story.id)

        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoritesVM.toggleFavorite(story: story)
            }
        } label: {
            Image(systemName: isFav ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFav ? .red : .secondary)
                .symbolEffect(.bounce, value: isFav)
        }
        .accessibilityLabel(isFav ? "Remove from favorites" : "Add to favorites")
    }
}
