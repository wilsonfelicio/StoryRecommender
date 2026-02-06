import Foundation

enum Constants {
    static let wordsPerMinute = 200
    static let maxHistoryEntries = 50
    static let maxFavorites = 100

    static let gutenbergBlocklistSubjects = [
        "horror", "violence", "romance", "war", "death",
        "murder", "crime", "gothic", "erotic", "adult"
    ]

    static let themeSearchTerms: [StoryTheme: [String]] = [
        .nature: ["nature", "forest", "garden", "seasons", "flowers"],
        .animals: ["animals", "rabbit", "bear", "dog", "cat", "bird"],
        .music: ["music", "song", "singing", "dance"],
        .space: ["moon", "stars", "sun", "sky", "night"],
        .friendship: ["friendship", "friends", "kindness", "love"],
        .fantasy: ["fairy", "magic", "dragon", "enchanted", "wizard"],
        .royalty: ["king", "queen", "prince", "princess", "castle"],
        .dinosaurs: ["dinosaur", "prehistoric", "fossil", "jurassic"],
        .ocean: ["ocean", "sea", "fish", "underwater", "mermaid"],
        .superheroes: ["hero", "superhero", "powers", "rescue", "brave"],
        .cooking: ["cooking", "baking", "kitchen", "recipe", "food"],
    ]

    static let moodSearchTerms: [StoryMood: [String]] = [
        .funny: ["humor", "funny", "comedy", "jest"],
        .adventure: ["adventure", "journey", "quest", "voyage"],
        .calming: ["gentle", "peaceful", "lullaby", "bedtime"],
        .educational: ["fable", "lesson", "moral", "knowledge"],
        .suspenseful: ["mystery", "suspense", "surprise", "secret"],
        .heartwarming: ["heartwarming", "touching", "sweet", "caring"],
        .silly: ["silly", "absurd", "goofy", "wacky"],
    ]
}
