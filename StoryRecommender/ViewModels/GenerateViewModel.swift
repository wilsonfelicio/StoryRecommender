import Foundation

@Observable
final class GenerateViewModel {
    var preferences = StorageService.shared.loadPreferences()
    var customPrompt = ""
    var characterName = ""

    // Generation state
    enum State: Equatable {
        case idle
        case generating
        case done(Story)
        case error(String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle): true
            case (.generating, .generating): true
            case (.done(let a), .done(let b)): a.id == b.id
            case (.error(let a), .error(let b)): a == b
            default: false
            }
        }
    }

    var state: State = .idle
    var streamedText = ""

    private var generationTask: Task<Void, Never>?

    var isGenerating: Bool {
        state == .generating
    }

    var hasAPIKey: Bool {
        LLMSettings.shared.hasAPIKey
    }

    func generate() {
        generationTask?.cancel()
        state = .generating
        streamedText = ""

        var prefs = preferences
        prefs.customPrompt = customPrompt.isEmpty ? nil : customPrompt
        prefs.characterName = characterName.isEmpty ? nil : characterName

        generationTask = Task { @MainActor in
            do {
                let stream = try await LLMService.shared.generateStream(preferences: prefs)
                var fullText = ""

                for try await chunk in stream {
                    if Task.isCancelled { return }
                    fullText += chunk
                    streamedText = fullText
                }

                // Parse title from first line
                let lines = fullText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")
                var title = "A Bedtime Story"
                var content = fullText

                if let firstLine = lines.first,
                   firstLine.count < 80 {
                    title = firstLine
                        .replacingOccurrences(of: "^#+\\s*", with: "", options: .regularExpression)
                        .replacingOccurrences(of: "^\\*+|\\*+$", with: "", options: .regularExpression)
                        .trimmingCharacters(in: .whitespaces)
                    content = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                }

                let story = Story(
                    id: "gen-\(UUID().uuidString.prefix(8).lowercased())",
                    title: title,
                    author: "AI Storyteller (\(LLMSettings.shared.selectedProvider.displayName))",
                    source: .generated,
                    content: content,
                    summary: String(content.prefix(150)).replacingOccurrences(of: "\\s+\\S*$", with: "", options: .regularExpression) + "...",
                    length: prefs.length,
                    mood: [prefs.mood],
                    themes: prefs.themes,
                    readingTimeMinutes: TimeUtilities.estimateReadingTime(text: content),
                    coverEmoji: "✨"
                )

                StorageService.shared.saveGeneratedStory(story)
                state = .done(story)
            } catch {
                if !Task.isCancelled {
                    state = .error(error.localizedDescription)
                }
            }
        }
    }

    func reset() {
        generationTask?.cancel()
        state = .idle
        streamedText = ""
    }
}
