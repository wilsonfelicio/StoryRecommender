import Foundation

struct FavoriteEntry: Codable, Identifiable, Equatable {
    let storyId: String
    let title: String
    let author: String
    let coverEmoji: String
    let source: StorySource
    let savedAt: Date

    var id: String { storyId }

    init(from story: Story) {
        self.storyId = story.id
        self.title = story.title
        self.author = story.author
        self.coverEmoji = story.coverEmoji
        self.source = story.source
        self.savedAt = Date()
    }

    init(storyId: String, title: String, author: String, coverEmoji: String, source: StorySource, savedAt: Date) {
        self.storyId = storyId
        self.title = title
        self.author = author
        self.coverEmoji = coverEmoji
        self.source = source
        self.savedAt = savedAt
    }
}
