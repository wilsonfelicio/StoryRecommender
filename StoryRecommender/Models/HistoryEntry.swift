import Foundation

struct HistoryEntry: Codable, Identifiable, Equatable {
    let storyId: String
    let title: String
    let author: String
    let coverEmoji: String
    let source: StorySource
    var lastReadAt: Date
    var scrollPosition: Double

    var id: String { storyId }

    init(from story: Story) {
        self.storyId = story.id
        self.title = story.title
        self.author = story.author
        self.coverEmoji = story.coverEmoji
        self.source = story.source
        self.lastReadAt = Date()
        self.scrollPosition = 0
    }

    init(storyId: String, title: String, author: String, coverEmoji: String, source: StorySource, lastReadAt: Date, scrollPosition: Double) {
        self.storyId = storyId
        self.title = title
        self.author = author
        self.coverEmoji = coverEmoji
        self.source = source
        self.lastReadAt = lastReadAt
        self.scrollPosition = scrollPosition
    }
}
