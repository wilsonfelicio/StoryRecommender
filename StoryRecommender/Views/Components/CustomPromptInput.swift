import SwiftUI

struct CustomPromptInput: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Story Idea (Optional)")
                .font(.headline)

            TextField("e.g., A brave little mouse who learns to fly...", text: $text, axis: .vertical)
                .lineLimit(3...6)
                .textFieldStyle(.plain)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
}
