import SwiftUI

struct NarratorPickerView: View {
    @Binding var selectedCharacter: NarratorCharacter?
    let onStartReading: (NarratorCharacter) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Choose Your Narrator")
                        .font(.title2.weight(.bold))
                    Text("Pick a character to read the story aloud")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(NarratorCharacter.allCases) { character in
                            NarratorCardView(
                                character: character,
                                isSelected: selectedCharacter == character
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedCharacter = character
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Button {
                    if let character = selectedCharacter {
                        onStartReading(character)
                        dismiss()
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Reading")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .padding(.horizontal)
                .disabled(selectedCharacter == nil)

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct NarratorCardView: View {
    let character: NarratorCharacter
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(character.emoji)
                .font(.system(size: 48))
                .scaleEffect(isSelected ? 1.15 : 1.0)

            Text(character.name)
                .font(.subheadline.weight(.semibold))

            Text(character.characterDescription)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 120)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.indigo.opacity(0.15) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(isSelected ? Color.indigo : .clear, lineWidth: 2)
        )
    }
}
