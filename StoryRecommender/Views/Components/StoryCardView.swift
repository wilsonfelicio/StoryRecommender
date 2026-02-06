import SwiftUI

struct StoryCardView: View {
    let story: Story
    var showSource = false

    var body: some View {
        HStack(spacing: 14) {
            Text(story.coverEmoji)
                .font(.system(size: 40))
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(story.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Label("\(story.readingTimeMinutes) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if showSource {
                        SourceBadge(source: story.source)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(story.title) by \(story.author), \(story.readingTimeMinutes) minute read")
    }
}
