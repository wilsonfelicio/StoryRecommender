import Foundation

actor LLMService {
    static let shared = LLMService()

    private let systemPrompt = """
    You are a warm, imaginative children's storyteller. Your stories are:
    - Age-appropriate and positive
    - Engaging with vivid, sensory descriptions
    - Have a clear beginning, middle, and end
    - Include a gentle moral or lesson when appropriate
    - Feature diverse characters and inclusive themes

    Adapt your vocabulary, sentence complexity, and story depth to the specified age range:
    - Toddler (2-3): Very simple sentences, repetitive patterns, familiar objects
    - Preschool (4-5): Simple plots, basic emotions, gentle lessons
    - Early Reader (6-8): More complex plots, richer vocabulary, chapter-like structure
    - Middle Grade (9-12): Deeper themes, nuanced characters, sophisticated vocabulary

    IMPORTANT: You must detect the language of the user's story idea. If the story idea is written in Portuguese, write the entire story in Brazilian Portuguese (pt-BR). If the story idea is written in English, write the entire story in English. If no story idea is provided, default to Brazilian Portuguese (pt-BR).

    Write the story title on the first line (no formatting), then a blank line, then the story. Do not include any meta-commentary, just the story itself.
    """

    enum LLMError: LocalizedError {
        case noAPIKey
        case invalidResponse(Int)
        case networkError(Error)
        case decodingError

        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                "No API key configured. Go to Settings to add your API key."
            case .invalidResponse(let code):
                "API returned error \(code)."
            case .networkError(let error):
                "Network error: \(error.localizedDescription)"
            case .decodingError:
                "Failed to parse response."
            }
        }
    }

    // MARK: - Public API

    func generateStream(preferences: StoryPreferences) throws -> AsyncThrowingStream<String, Error> {
        let settings = LLMSettings.shared
        let provider = settings.selectedProvider

        guard let apiKey = settings.resolvedAPIKey else {
            throw LLMError.noAPIKey
        }

        let userPrompt = buildUserPrompt(preferences)

        let request = try buildRequest(
            provider: provider,
            apiKey: apiKey,
            systemPrompt: systemPrompt,
            userPrompt: userPrompt
        )

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    if let httpResponse = response as? HTTPURLResponse,
                       httpResponse.statusCode != 200 {
                        continuation.finish(throwing: LLMError.invalidResponse(httpResponse.statusCode))
                        return
                    }

                    for try await line in bytes.lines {
                        if let text = self.parseSSELine(line, provider: provider) {
                            continuation.yield(text)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: LLMError.networkError(error))
                }
            }
        }
    }

    // MARK: - Request Building

    private func buildRequest(
        provider: LLMProvider,
        apiKey: String,
        systemPrompt: String,
        userPrompt: String
    ) throws -> URLRequest {
        switch provider {
        case .anthropic:
            return try buildAnthropicRequest(apiKey: apiKey, systemPrompt: systemPrompt, userPrompt: userPrompt)
        case .openai:
            return try buildOpenAIRequest(apiKey: apiKey, systemPrompt: systemPrompt, userPrompt: userPrompt)
        case .gemini:
            return try buildGeminiRequest(apiKey: apiKey, systemPrompt: systemPrompt, userPrompt: userPrompt)
        }
    }

    private func buildAnthropicRequest(apiKey: String, systemPrompt: String, userPrompt: String) throws -> URLRequest {
        let body: [String: Any] = [
            "model": LLMProvider.anthropic.defaultModel,
            "max_tokens": LLMProvider.anthropic.defaultMaxTokens,
            "stream": true,
            "system": systemPrompt,
            "messages": [["role": "user", "content": userPrompt]]
        ]
        var request = URLRequest(url: LLMProvider.anthropic.endpoint())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func buildOpenAIRequest(apiKey: String, systemPrompt: String, userPrompt: String) throws -> URLRequest {
        let body: [String: Any] = [
            "model": LLMProvider.openai.defaultModel,
            "max_tokens": LLMProvider.openai.defaultMaxTokens,
            "stream": true,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ]
        ]
        var request = URLRequest(url: LLMProvider.openai.endpoint())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func buildGeminiRequest(apiKey: String, systemPrompt: String, userPrompt: String) throws -> URLRequest {
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": userPrompt]]]
            ],
            "systemInstruction": [
                "parts": [["text": systemPrompt]]
            ],
            "generationConfig": [
                "maxOutputTokens": LLMProvider.gemini.defaultMaxTokens
            ]
        ]
        var request = URLRequest(url: LLMProvider.gemini.endpoint(apiKey: apiKey))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    // MARK: - SSE Parsing

    private nonisolated func parseSSELine(_ line: String, provider: LLMProvider) -> String? {
        guard line.hasPrefix("data: ") else { return nil }
        let jsonStr = String(line.dropFirst(6))
        if jsonStr == "[DONE]" { return nil }

        guard let data = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        switch provider {
        case .anthropic:
            return parseAnthropicDelta(json)
        case .openai:
            return parseOpenAIDelta(json)
        case .gemini:
            return parseGeminiDelta(json)
        }
    }

    private nonisolated func parseAnthropicDelta(_ json: [String: Any]) -> String? {
        guard let type = json["type"] as? String,
              type == "content_block_delta",
              let delta = json["delta"] as? [String: Any],
              let deltaType = delta["type"] as? String,
              deltaType == "text_delta",
              let text = delta["text"] as? String else {
            return nil
        }
        return text
    }

    private nonisolated func parseOpenAIDelta(_ json: [String: Any]) -> String? {
        guard let choices = json["choices"] as? [[String: Any]],
              let first = choices.first,
              let delta = first["delta"] as? [String: Any],
              let content = delta["content"] as? String else {
            return nil
        }
        return content
    }

    private nonisolated func parseGeminiDelta(_ json: [String: Any]) -> String? {
        guard let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            return nil
        }
        return text
    }

    // MARK: - Prompt Construction

    private nonisolated func buildUserPrompt(_ prefs: StoryPreferences) -> String {
        let range = prefs.length.wordRange
        var parts = ["Write a \(prefs.mood.rawValue) bedtime story that is \(range.lowerBound)-\(range.upperBound) words long."]

        // Age range
        parts.append("Target age range: \(prefs.ageRange.label) (\(prefs.ageRange.ageDescription)).")

        // Story style
        parts.append("Story style: \(prefs.storyStyle.label).")

        // Main character
        if let name = prefs.characterName, !name.isEmpty {
            parts.append("The main character is \(prefs.mainCharacter.label.lowercased()) named \(name).")
        } else {
            parts.append("The main character should be \(prefs.mainCharacter.label.lowercased()).")
        }

        if !prefs.themes.isEmpty {
            let themeNames = prefs.themes.map(\.rawValue).joined(separator: ", ")
            parts.append("Themes: \(themeNames).")
        }

        if let customPrompt = prefs.customPrompt, !customPrompt.isEmpty {
            parts.append("Story idea: \(customPrompt)")
            parts.append("Write the story in the same language as the story idea above.")
        } else {
            parts.append("Write the story in Brazilian Portuguese (pt-BR).")
        }

        return parts.joined(separator: " ")
    }
}
