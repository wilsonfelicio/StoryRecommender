import SwiftUI

struct LengthSelectorView: View {
    @Binding var selected: StoryLength

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Story Length")
                .font(.headline)

            HStack(spacing: 10) {
                ForEach(StoryLength.allCases) { length in
                    Button {
                        selected = length
                    } label: {
                        VStack(spacing: 4) {
                            Text(length.emoji)
                                .font(.title2)
                            Text(length.label)
                                .font(.subheadline.weight(.medium))
                            Text(length.description)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected == length ? Color.indigo.opacity(0.15) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selected == length ? Color.indigo : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct MoodSelectorView: View {
    @Binding var selected: StoryMood

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(StoryMood.allCases) { mood in
                    Button {
                        selected = mood
                    } label: {
                        HStack(spacing: 8) {
                            Text(mood.emoji)
                                .font(.title3)
                            Text(mood.label)
                                .font(.subheadline.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected == mood ? Color.indigo.opacity(0.15) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selected == mood ? Color.indigo : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ThemeSelectorView: View {
    @Binding var selected: [StoryTheme]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Themes")
                .font(.headline)

            Text("Pick one or more")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(StoryTheme.allCases) { theme in
                    Button {
                        toggleTheme(theme)
                    } label: {
                        VStack(spacing: 4) {
                            Text(theme.emoji)
                                .font(.title2)
                            Text(theme.label)
                                .font(.caption.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected.contains(theme) ? Color.indigo.opacity(0.15) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selected.contains(theme) ? Color.indigo : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toggleTheme(_ theme: StoryTheme) {
        if let index = selected.firstIndex(of: theme) {
            if selected.count > 1 {
                selected.remove(at: index)
            }
        } else {
            selected.append(theme)
        }
    }
}

struct AgeRangeSelectorView: View {
    @Binding var selected: AgeRange

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Age Range")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(AgeRange.allCases) { age in
                    Button {
                        selected = age
                    } label: {
                        VStack(spacing: 4) {
                            Text(age.emoji)
                                .font(.title2)
                            Text(age.label)
                                .font(.subheadline.weight(.medium))
                            Text(age.ageDescription)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected == age ? Color.indigo.opacity(0.15) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selected == age ? Color.indigo : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct StoryStyleSelectorView: View {
    @Binding var selected: StoryStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Story Style")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(StoryStyle.allCases) { style in
                    Button {
                        selected = style
                    } label: {
                        VStack(spacing: 4) {
                            Text(style.emoji)
                                .font(.title2)
                            Text(style.label)
                                .font(.subheadline.weight(.medium))
                            Text(style.description)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected == style ? Color.indigo.opacity(0.15) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selected == style ? Color.indigo : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct MainCharacterSelectorView: View {
    @Binding var selected: MainCharacter
    @Binding var characterName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Main Character")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(MainCharacter.allCases) { character in
                    Button {
                        selected = character
                    } label: {
                        HStack(spacing: 8) {
                            Text(character.emoji)
                                .font(.title3)
                            Text(character.label)
                                .font(.subheadline.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selected == character ? Color.indigo.opacity(0.15) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(selected == character ? Color.indigo : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            TextField("Character name (optional)", text: $characterName)
                .textFieldStyle(.roundedBorder)
                .font(.subheadline)
        }
    }
}
