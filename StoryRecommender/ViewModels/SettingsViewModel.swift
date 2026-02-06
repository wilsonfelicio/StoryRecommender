import Foundation

@Observable
final class SettingsViewModel {
    private let settings = LLMSettings.shared

    var selectedProvider: LLMProvider {
        get { settings.selectedProvider }
        set { settings.selectedProvider = newValue }
    }

    var apiKeyInput = ""
    var isSaving = false
    var saveMessage: String?
    var saveSuccess = false
    var isTestingKey = false
    var testResult: String?
    var testSuccess = false

    func loadCurrentKey() {
        if let key = settings.userAPIKey(for: selectedProvider), !key.isEmpty {
            if key.count > 12 {
                apiKeyInput = String(key.prefix(8)) + "..." + String(key.suffix(4))
            } else {
                apiKeyInput = key
            }
        } else {
            apiKeyInput = ""
        }
        saveMessage = nil
        testResult = nil
    }

    var isUsingBuiltInKey: Bool {
        settings.isUsingBuiltInKey
    }

    var hasUserKey: Bool {
        if let key = settings.userAPIKey(for: selectedProvider), !key.isEmpty {
            return true
        }
        return false
    }

    func saveKey() {
        isSaving = true
        do {
            if apiKeyInput.contains("...") {
                saveMessage = "No changes made."
                saveSuccess = true
            } else {
                try settings.saveAPIKey(apiKeyInput, for: selectedProvider)
                saveMessage = apiKeyInput.isEmpty ? "Key removed." : "Key saved securely."
                saveSuccess = true
            }
        } catch {
            saveMessage = "Failed to save: \(error.localizedDescription)"
            saveSuccess = false
        }
        isSaving = false
    }

    func deleteKey() {
        settings.deleteAPIKey(for: selectedProvider)
        apiKeyInput = ""
        saveMessage = "Key removed."
        saveSuccess = true
        testResult = nil
    }

    func testKey() {
        isTestingKey = true
        testResult = nil

        Task { @MainActor in
            do {
                let testPrefs = StoryPreferences(
                    length: .short,
                    mood: .calming,
                    themes: [.nature],
                    ageRange: .preschool,
                    storyStyle: .classicFairytale,
                    mainCharacter: .child,
                    customPrompt: "Say 'Hello' in one word."
                )
                let stream = try await LLMService.shared.generateStream(preferences: testPrefs)

                var received = false
                for try await chunk in stream {
                    if !chunk.isEmpty {
                        received = true
                        break
                    }
                }

                testResult = received ? "Connection successful!" : "No response received."
                testSuccess = received
            } catch {
                testResult = "Test failed: \(error.localizedDescription)"
                testSuccess = false
            }
            isTestingKey = false
        }
    }
}
