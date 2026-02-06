import Foundation

actor GutenbergService {
    static let shared = GutenbergService()

    private let baseURL = "https://gutendex.com"
    private let session = URLSession.shared

    struct GutenbergBook: Decodable {
        let id: Int
        let title: String
        let authors: [Author]
        let subjects: [String]
        let formats: [String: String]

        struct Author: Decodable {
            let name: String
        }
    }

    struct SearchResponse: Decodable {
        let count: Int
        let results: [GutenbergBook]
    }

    enum GutenbergError: LocalizedError {
        case noResults
        case noTextAvailable
        case networkError(Error)

        var errorDescription: String? {
            switch self {
            case .noResults: "No stories found matching your preferences."
            case .noTextAvailable: "This book's text is not available."
            case .networkError(let error): "Network error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Search

    func search(themes: [StoryTheme], mood: StoryMood?) async throws -> [Story] {
        let query = buildSearchTerms(themes: themes, mood: mood)
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/books/?search=\(encoded)&languages=en&mime_type=text/plain")!

        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)

        let childFriendly = response.results.filter { isChildFriendly(subjects: $0.subjects) }
        guard !childFriendly.isEmpty else { throw GutenbergError.noResults }

        return childFriendly.prefix(8).map { book in
            Story(
                id: "gut-\(book.id)",
                title: cleanTitle(book.title),
                author: book.authors.first?.name ?? "Unknown",
                source: .gutenberg,
                content: "", // loaded on demand
                summary: "A classic story from Project Gutenberg",
                length: .medium,
                mood: mood.map { [$0] } ?? [.adventure],
                themes: themes,
                readingTimeMinutes: 10,
                coverEmoji: "📜"
            )
        }
    }

    // MARK: - Fetch Full Text

    func fetchFullText(bookId: Int) async throws -> String {
        let url = URL(string: "\(baseURL)/books/\(bookId)")!
        let (data, _) = try await session.data(from: url)
        let book = try JSONDecoder().decode(GutenbergBook.self, from: data)

        // Find plain text URL
        guard let textURL = book.formats["text/plain; charset=utf-8"]
                ?? book.formats["text/plain"]
                ?? book.formats.first(where: { $0.key.hasPrefix("text/plain") })?.value else {
            throw GutenbergError.noTextAvailable
        }

        let (textData, _) = try await session.data(from: URL(string: textURL)!)
        let text = String(data: textData, encoding: .utf8) ?? ""
        return TextCleaner.clean(text)
    }

    // MARK: - Helpers

    private func buildSearchTerms(themes: [StoryTheme], mood: StoryMood?) -> String {
        var terms: [String] = []
        for theme in themes {
            if let themeTerms = Constants.themeSearchTerms[theme], let first = themeTerms.first {
                terms.append(first)
            }
        }
        if let mood = mood, let moodTerms = Constants.moodSearchTerms[mood], let first = moodTerms.first {
            terms.append(first)
        }
        if terms.isEmpty {
            terms.append(contentsOf: ["children", "fairy"])
        }
        return terms.joined(separator: " ")
    }

    private func isChildFriendly(subjects: [String]) -> Bool {
        let lower = subjects.map { $0.lowercased() }
        return !lower.contains { subject in
            Constants.gutenbergBlocklistSubjects.contains { blocked in
                subject.contains(blocked)
            }
        }
    }

    private func cleanTitle(_ title: String) -> String {
        // Remove subtitles after semicolons or long dashes
        let cleaned = title.components(separatedBy: ";").first ?? title
        return cleaned.components(separatedBy: " — ").first?.trimmingCharacters(in: .whitespaces) ?? cleaned
    }
}
