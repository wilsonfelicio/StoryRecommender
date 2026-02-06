import Foundation

@Observable
final class LLMSettings {
    static let shared = LLMSettings()

    private let providerKey = "llm_selected_provider"

    // MARK: - Selected Provider

    var selectedProvider: LLMProvider {
        didSet {
            UserDefaults.standard.set(selectedProvider.rawValue, forKey: providerKey)
        }
    }

    // MARK: - Init

    private init() {
        if let raw = UserDefaults.standard.string(forKey: providerKey),
           let provider = LLMProvider(rawValue: raw) {
            self.selectedProvider = provider
        } else {
            self.selectedProvider = .anthropic
        }
    }

    // MARK: - API Key Management

    private func keychainKey(for provider: LLMProvider) -> String {
        "llm_api_key_\(provider.rawValue)"
    }

    func userAPIKey(for provider: LLMProvider) -> String? {
        KeychainService.load(key: keychainKey(for: provider))
    }

    func saveAPIKey(_ key: String, for provider: LLMProvider) throws {
        if key.isEmpty {
            KeychainService.delete(key: keychainKey(for: provider))
        } else {
            try KeychainService.save(key: keychainKey(for: provider), value: key)
        }
    }

    func deleteAPIKey(for provider: LLMProvider) {
        KeychainService.delete(key: keychainKey(for: provider))
    }

    // MARK: - Resolved Key

    var resolvedAPIKey: String? {
        if let userKey = userAPIKey(for: selectedProvider), !userKey.isEmpty {
            return userKey
        }
        if selectedProvider == .anthropic, APIConfig.hasBuiltInAPIKey {
            return APIConfig.builtInAnthropicAPIKey
        }
        return nil
    }

    var hasAPIKey: Bool {
        resolvedAPIKey != nil
    }

    var isUsingBuiltInKey: Bool {
        let userKey = userAPIKey(for: selectedProvider)
        let hasUserKey = userKey != nil && !userKey!.isEmpty
        return !hasUserKey && selectedProvider == .anthropic && APIConfig.hasBuiltInAPIKey
    }
}
