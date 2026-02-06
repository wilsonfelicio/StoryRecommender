import Foundation

enum NarratorCharacter: String, CaseIterable, Identifiable, Codable {
    case bravePuppy
    case curiousKitten
    case wiseOwl
    case playfulParrot

    var id: String { rawValue }

    var name: String {
        switch self {
        case .bravePuppy: "Bidu"
        case .curiousKitten: "Mimi"
        case .wiseOwl: "Coruja"
        case .playfulParrot: "Louro"
        }
    }

    var emoji: String {
        switch self {
        case .bravePuppy: "🐕"
        case .curiousKitten: "🐱"
        case .wiseOwl: "🦉"
        case .playfulParrot: "🦜"
        }
    }

    var characterDescription: String {
        switch self {
        case .bravePuppy: "Cheio de energia e coragem!"
        case .curiousKitten: "Calma e cheia de curiosidade"
        case .wiseOwl: "Sábia e tranquila"
        case .playfulParrot: "Divertido e animado!"
        }
    }

    var voicePitch: Float {
        switch self {
        case .bravePuppy: 1.2
        case .curiousKitten: 1.1
        case .wiseOwl: 0.85
        case .playfulParrot: 1.3
        }
    }

    var voiceRate: Float {
        switch self {
        case .bravePuppy: 0.52
        case .curiousKitten: 0.45
        case .wiseOwl: 0.40
        case .playfulParrot: 0.55
        }
    }

    var themeColorName: String {
        switch self {
        case .bravePuppy: "orange"
        case .curiousKitten: "pink"
        case .wiseOwl: "indigo"
        case .playfulParrot: "green"
        }
    }
}
