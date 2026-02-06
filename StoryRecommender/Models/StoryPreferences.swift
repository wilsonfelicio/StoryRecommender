import Foundation

struct StoryPreferences: Codable, Equatable {
    var length: StoryLength
    var mood: StoryMood
    var themes: [StoryTheme]
    var ageRange: AgeRange
    var storyStyle: StoryStyle
    var mainCharacter: MainCharacter
    var characterName: String?
    var customPrompt: String?

    static let `default` = StoryPreferences(
        length: .medium,
        mood: .adventure,
        themes: [.animals],
        ageRange: .preschool,
        storyStyle: .classicFairytale,
        mainCharacter: .child
    )
}
