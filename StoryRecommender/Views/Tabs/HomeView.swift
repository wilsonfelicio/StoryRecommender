import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var navigateToResults = false

    var body: some View {
        Group {
            if viewModel.isSearching {
                searchResultsList
            } else {
                preferencesScrollView
            }
        }
        .navigationTitle("Story Time")
        .searchable(text: $viewModel.searchText, prompt: "Search stories by title, author, theme...")
        .onChange(of: viewModel.searchText) {
            viewModel.performSearch()
        }
        .navigationDestination(isPresented: $navigateToResults) {
            ResultsView(preferences: viewModel.preferences)
        }
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        Group {
            if viewModel.searchResults.isEmpty {
                EmptyStateView(
                    emoji: "🔍",
                    title: "No Stories Found",
                    message: "Try a different search term like a title, author, or theme."
                )
            } else {
                List(viewModel.searchResults) { story in
                    NavigationLink {
                        StoryReaderView(storyId: story.id)
                    } label: {
                        StoryCardView(story: story, showSource: true)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    // MARK: - Preferences

    private var preferencesScrollView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Greeting
                VStack(spacing: 4) {
                    Text(viewModel.greetingEmoji)
                        .font(.system(size: 48))
                    Text("\(viewModel.greeting)!")
                        .font(.largeTitle.weight(.bold))
                    Text("What kind of story would you like tonight?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                // Preferences
                VStack(spacing: 20) {
                    LengthSelectorView(selected: $viewModel.preferences.length)
                        .onChange(of: viewModel.preferences.length) {
                            viewModel.savePreferences()
                        }

                    MoodSelectorView(selected: $viewModel.preferences.mood)
                        .onChange(of: viewModel.preferences.mood) {
                            viewModel.savePreferences()
                        }

                    ThemeSelectorView(selected: $viewModel.preferences.themes)
                        .onChange(of: viewModel.preferences.themes) {
                            viewModel.savePreferences()
                        }
                }
                .padding(.horizontal)

                // Find Stories Button
                Button {
                    navigateToResults = true
                } label: {
                    HStack {
                        Image(systemName: "sparkle.magnifyingglass")
                        Text("Find Stories")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .padding(.horizontal)
                .disabled(viewModel.preferences.themes.isEmpty)

                Spacer(minLength: 40)
            }
        }
    }
}
