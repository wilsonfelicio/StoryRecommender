import SwiftUI

struct GenerateView: View {
    @State private var viewModel = GenerateViewModel()
    @Environment(FavoritesViewModel.self) private var favoritesVM

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                generateForm
            case .generating:
                StreamingStoryView(text: viewModel.streamedText)
            case .done(let story):
                storyCompleteView(story: story)
            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Generate Story")
    }

    // MARK: - Form

    private var generateForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("✨")
                        .font(.system(size: 48))
                    Text("AI Story Generator")
                        .font(.title2.weight(.bold))
                    Text("Create a unique bedtime story with AI")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                if !viewModel.hasAPIKey {
                    noAPIKeyBanner
                }

                VStack(spacing: 20) {
                    AgeRangeSelectorView(selected: $viewModel.preferences.ageRange)
                    LengthSelectorView(selected: $viewModel.preferences.length)
                    MoodSelectorView(selected: $viewModel.preferences.mood)
                    StoryStyleSelectorView(selected: $viewModel.preferences.storyStyle)
                    MainCharacterSelectorView(
                        selected: $viewModel.preferences.mainCharacter,
                        characterName: $viewModel.characterName
                    )
                    ThemeSelectorView(selected: $viewModel.preferences.themes)
                    CustomPromptInput(text: $viewModel.customPrompt)
                }
                .padding(.horizontal)

                Button {
                    viewModel.generate()
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Generate Story")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .padding(.horizontal)
                .disabled(!viewModel.hasAPIKey || viewModel.preferences.themes.isEmpty)

                Spacer(minLength: 40)
            }
        }
    }

    private var noAPIKeyBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "key.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("API Key Required")
                    .font(.subheadline.weight(.medium))
                Text("Go to Settings to add your \(LLMSettings.shared.selectedProvider.displayName) API key")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        )
        .padding(.horizontal)
    }

    // MARK: - Complete

    private func storyCompleteView(story: Story) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("✨")
                        .font(.system(size: 48))
                    Text(story.title)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text("by AI Storyteller")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                // Story text
                Text(story.content)
                    .font(.system(size: 18, design: .serif))
                    .lineSpacing(9)
                    .padding(.horizontal)
                    .textSelection(.enabled)

                // Actions
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        FavoriteButton(story: story)

                        ShareLink(item: "\(story.title)\n\n\(story.content)") {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }

                        NavigationLink {
                            StoryReaderView(storyId: story.id)
                        } label: {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("Read Full Story")
                            }
                            .font(.headline)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                    }

                    Button {
                        viewModel.reset()
                    } label: {
                        Text("Generate Another")
                            .font(.subheadline.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 8)

                Spacer(minLength: 60)
            }
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Text("😕")
                .font(.system(size: 48))
            Text("Oops!")
                .font(.title3.weight(.semibold))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                viewModel.reset()
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 24)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
