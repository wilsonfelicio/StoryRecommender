import Foundation

enum LLMProvider: String, Codable, CaseIterable, Identifiable {
    case anthropic
    case openai
    case gemini

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .anthropic: "Anthropic (Claude)"
        case .openai: "OpenAI (GPT)"
        case .gemini: "Google (Gemini)"
        }
    }

    var iconName: String {
        switch self {
        case .anthropic: "brain.head.profile"
        case .openai: "sparkles"
        case .gemini: "diamond"
        }
    }

    var defaultModel: String {
        switch self {
        case .anthropic: "claude-sonnet-4-20250514"
        case .openai: "gpt-4o"
        case .gemini: "gemini-2.0-flash"
        }
    }

    var defaultMaxTokens: Int { 4096 }

    var apiKeyPlaceholder: String {
        switch self {
        case .anthropic: "sk-ant-api03-..."
        case .openai: "sk-..."
        case .gemini: "AIza..."
        }
    }

    func endpoint(model: String? = nil, apiKey: String? = nil) -> URL {
        switch self {
        case .anthropic:
            return URL(string: "https://api.anthropic.com/v1/messages")!
        case .openai:
            return URL(string: "https://api.openai.com/v1/chat/completions")!
        case .gemini:
            let m = model ?? defaultModel
            let k = apiKey ?? ""
            return URL(string:
                "https://generativelanguage.googleapis.com/v1beta/models/\(m):streamGenerateContent?alt=sse&key=\(k)"
            )!
        }
    }
}
