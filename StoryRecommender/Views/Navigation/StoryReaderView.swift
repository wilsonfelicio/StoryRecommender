import SwiftUI

struct StoryReaderView: View {
    let storyId: String
    @State private var viewModel: StoryReaderViewModel
    @Environment(FavoritesViewModel.self) private var favoritesVM
    @Environment(HistoryViewModel.self) private var historyVM

    init(storyId: String) {
        self.storyId = storyId
        self._viewModel = State(initialValue: StoryReaderViewModel(storyId: storyId))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading story...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack(spacing: 12) {
                        Text("😕")
                            .font(.system(size: 48))
                        Text("Couldn't Load Story")
                            .font(.title3.weight(.semibold))
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let story = viewModel.story {
                    StoryContentView(story: story, fontSize: viewModel.fontSize)
                }
            }

            // Narrator avatar overlay
            if viewModel.isNarrating, let narrator = viewModel.selectedNarrator {
                NarratorAvatarView(
                    character: narrator,
                    isSpeaking: viewModel.speechService.isSpeaking,
                    playbackState: viewModel.speechService.playbackState,
                    onPlayPause: { viewModel.toggleNarrationPlayPause() },
                    onStop: { viewModel.stopNarration() }
                )
                .padding(.trailing, 16)
                .padding(.bottom, 24)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.isNarrating)
            }
        }
        .navigationTitle(viewModel.story?.title ?? "Story")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let story = viewModel.story {
                    FavoriteButton(story: story)
                }

                // Read Aloud button
                if viewModel.story != nil {
                    Button {
                        if viewModel.isNarrating {
                            viewModel.stopNarration()
                        } else {
                            viewModel.showNarratorPicker()
                        }
                    } label: {
                        Image(systemName: viewModel.isNarrating
                            ? "speaker.wave.2.fill"
                            : "speaker.wave.2")
                    }
                    .accessibilityLabel(viewModel.isNarrating
                        ? "Stop narration" : "Read aloud")
                }

                Menu {
                    Button {
                        viewModel.increaseFontSize()
                    } label: {
                        Label("Larger Text", systemImage: "textformat.size.larger")
                    }

                    Button {
                        viewModel.decreaseFontSize()
                    } label: {
                        Label("Smaller Text", systemImage: "textformat.size.smaller")
                    }
                } label: {
                    Image(systemName: "textformat.size")
                }
            }
        }
        .sheet(isPresented: $viewModel.isNarratorPickerPresented) {
            NarratorPickerView(
                selectedCharacter: $viewModel.selectedNarrator
            ) { character in
                viewModel.startNarration(character: character)
            }
        }
        .onAppear {
            viewModel.loadStory()
            // Record in history after a slight delay to ensure story is loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let story = viewModel.story {
                    historyVM.recordReading(story: story)
                }
            }
        }
        .onDisappear {
            viewModel.stopNarration()
        }
    }
}

struct StoryContentView: View {
    let story: Story
    let fontSize: CGFloat

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(story.coverEmoji)
                        .font(.system(size: 56))

                    Text(story.title)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)

                    Text("by \(story.author)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Label("\(story.readingTimeMinutes) min read", systemImage: "clock")
                        SourceBadge(source: story.source)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                Divider()
                    .padding(.horizontal)

                // Story Content
                Text(story.content)
                    .font(.system(size: fontSize, design: .serif))
                    .lineSpacing(fontSize * 0.5)
                    .padding(.horizontal)
                    .textSelection(.enabled)

                Spacer(minLength: 60)
            }
            .padding(.bottom, 40)
        }
    }
}
