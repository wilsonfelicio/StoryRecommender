import SwiftUI

struct ResultsView: View {
    let preferences: StoryPreferences
    @State private var viewModel: ResultsViewModel

    init(preferences: StoryPreferences) {
        self.preferences = preferences
        self._viewModel = State(initialValue: ResultsViewModel(preferences: preferences))
    }

    var body: some View {
        List {
            // Curated Section
            if !viewModel.curatedStories.isEmpty {
                Section {
                    ForEach(viewModel.curatedStories) { story in
                        NavigationLink {
                            StoryReaderView(storyId: story.id)
                        } label: {
                            StoryCardView(story: story)
                        }
                    }
                } header: {
                    Label("Curated Stories", systemImage: "star.fill")
                }
            }

            // Gutenberg Section
            Section {
                if viewModel.isLoadingGutenberg {
                    HStack {
                        ProgressView()
                        Text("Searching Project Gutenberg...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                } else if let error = viewModel.gutenbergError {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Couldn't load Gutenberg stories")
                            .font(.subheadline.weight(.medium))
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                } else {
                    ForEach(viewModel.gutenbergStories) { story in
                        NavigationLink {
                            StoryReaderView(storyId: story.id)
                        } label: {
                            StoryCardView(story: story, showSource: true)
                        }
                    }
                }
            } header: {
                Label("From Project Gutenberg", systemImage: "books.vertical.fill")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Stories For You")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if viewModel.curatedStories.isEmpty {
                viewModel.loadStories()
            }
        }
    }
}
