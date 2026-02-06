import SwiftUI

struct FavoritesView: View {
    @Environment(FavoritesViewModel.self) private var favoritesVM

    var body: some View {
        Group {
            if favoritesVM.isEmpty {
                EmptyStateView(
                    emoji: "💝",
                    title: "No Favorites Yet",
                    message: "Stories you love will appear here. Tap the heart while reading to save your favorites."
                )
            } else {
                List {
                    ForEach(favoritesVM.favorites) { entry in
                        NavigationLink {
                            StoryReaderView(storyId: entry.storyId)
                        } label: {
                            FavoriteRowView(entry: entry)
                        }
                    }
                    .onDelete(perform: deleteFavorites)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Favorites")
    }

    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let entry = favoritesVM.favorites[index]
            favoritesVM.removeFavorite(storyId: entry.storyId)
        }
    }
}

struct FavoriteRowView: View {
    let entry: FavoriteEntry

    var body: some View {
        HStack(spacing: 14) {
            Text(entry.coverEmoji)
                .font(.system(size: 36))
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(entry.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    SourceBadge(source: entry.source)
                    Text(RelativeDateFormatter.string(from: entry.savedAt))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
