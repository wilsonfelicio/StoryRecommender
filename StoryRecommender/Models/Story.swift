import Foundation

// MARK: - Enums

enum StoryLength: String, Codable, CaseIterable, Identifiable {
    case short, medium, long

    var id: String { rawValue }

    var label: String {
        switch self {
        case .short: "Short"
        case .medium: "Medium"
        case .long: "Long"
        }
    }

    var description: String {
        switch self {
        case .short: "2-3 min read"
        case .medium: "5-7 min read"
        case .long: "10-15 min read"
        }
    }

    var emoji: String {
        switch self {
        case .short: "🌙"
        case .medium: "🌟"
        case .long: "📖"
        }
    }

    var wordRange: ClosedRange<Int> {
        switch self {
        case .short: 300...600
        case .medium: 800...1400
        case .long: 1800...3000
        }
    }
}

enum StoryMood: String, Codable, CaseIterable, Identifiable {
    case funny, adventure, calming, educational, suspenseful, heartwarming, silly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .funny: "Funny"
        case .adventure: "Adventure"
        case .calming: "Calming"
        case .educational: "Educational"
        case .suspenseful: "Suspenseful"
        case .heartwarming: "Heartwarming"
        case .silly: "Silly"
        }
    }

    var emoji: String {
        switch self {
        case .funny: "😄"
        case .adventure: "🗺️"
        case .calming: "😌"
        case .educational: "🧠"
        case .suspenseful: "🫣"
        case .heartwarming: "💖"
        case .silly: "🤪"
        }
    }
}

enum StoryTheme: String, Codable, CaseIterable, Identifiable {
    case nature, animals, music, space, friendship, fantasy, royalty, dinosaurs, ocean, superheroes, cooking

    var id: String { rawValue }

    var label: String {
        switch self {
        case .nature: "Nature"
        case .animals: "Animals"
        case .music: "Music"
        case .space: "Space"
        case .friendship: "Friendship"
        case .fantasy: "Fantasy"
        case .royalty: "Royalty"
        case .dinosaurs: "Dinosaurs"
        case .ocean: "Ocean"
        case .superheroes: "Superheroes"
        case .cooking: "Cooking"
        }
    }

    var emoji: String {
        switch self {
        case .nature: "🌿"
        case .animals: "🐾"
        case .music: "🎵"
        case .space: "🚀"
        case .friendship: "🤝"
        case .fantasy: "🧙"
        case .royalty: "🏰"
        case .dinosaurs: "🦕"
        case .ocean: "🌊"
        case .superheroes: "🦸"
        case .cooking: "🍪"
        }
    }
}

enum AgeRange: String, Codable, CaseIterable, Identifiable {
    case toddler, preschool, earlyReader, middleGrade

    var id: String { rawValue }

    var label: String {
        switch self {
        case .toddler: "Toddler"
        case .preschool: "Preschool"
        case .earlyReader: "Early Reader"
        case .middleGrade: "Middle Grade"
        }
    }

    var ageDescription: String {
        switch self {
        case .toddler: "Ages 2-3"
        case .preschool: "Ages 4-5"
        case .earlyReader: "Ages 6-8"
        case .middleGrade: "Ages 9-12"
        }
    }

    var emoji: String {
        switch self {
        case .toddler: "👶"
        case .preschool: "🧒"
        case .earlyReader: "📚"
        case .middleGrade: "🧑"
        }
    }
}

enum StoryStyle: String, Codable, CaseIterable, Identifiable {
    case classicFairytale, rhyming, interactive, fable

    var id: String { rawValue }

    var label: String {
        switch self {
        case .classicFairytale: "Classic Fairytale"
        case .rhyming: "Rhyming"
        case .interactive: "Interactive"
        case .fable: "Fable"
        }
    }

    var emoji: String {
        switch self {
        case .classicFairytale: "📖"
        case .rhyming: "🔁"
        case .interactive: "🗣️"
        case .fable: "📝"
        }
    }

    var description: String {
        switch self {
        case .classicFairytale: "Once upon a time..."
        case .rhyming: "Rhythmic & repetitive"
        case .interactive: "Choose your path"
        case .fable: "With a moral lesson"
        }
    }
}

enum MainCharacter: String, Codable, CaseIterable, Identifiable {
    case child, animal, robot, magicalBeing

    var id: String { rawValue }

    var label: String {
        switch self {
        case .child: "A Child"
        case .animal: "An Animal"
        case .robot: "A Robot"
        case .magicalBeing: "Magical Being"
        }
    }

    var emoji: String {
        switch self {
        case .child: "🧒"
        case .animal: "🐻"
        case .robot: "🤖"
        case .magicalBeing: "👸"
        }
    }
}

enum StorySource: String, Codable {
    case curated, gutenberg, generated

    var label: String {
        switch self {
        case .curated: "Curated"
        case .gutenberg: "Gutenberg"
        case .generated: "AI Generated"
        }
    }
}

// MARK: - Story

struct Story: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let author: String
    let source: StorySource
    let content: String
    let summary: String
    let length: StoryLength
    let mood: [StoryMood]
    let themes: [StoryTheme]
    let readingTimeMinutes: Int
    let coverEmoji: String

    static func == (lhs: Story, rhs: Story) -> Bool {
        lhs.id == rhs.id
    }
}
