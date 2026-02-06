import Foundation

enum APIConfig {
    /// The built-in Anthropic API key from Info.plist/Secrets.xcconfig.
    static var builtInAnthropicAPIKey: String {
        guard let key = Bundle.main.infoDictionary?["ANTHROPIC_API_KEY"] as? String,
              !key.isEmpty,
              key != "your-api-key-here" else {
            return ""
        }
        return key
    }

    /// Whether a built-in Anthropic key exists in the bundle.
    static var hasBuiltInAPIKey: Bool {
        !builtInAnthropicAPIKey.isEmpty
    }
}
