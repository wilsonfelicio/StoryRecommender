import SwiftUI

struct SourceBadge: View {
    let source: StorySource

    var body: some View {
        Text(source.label)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(badgeColor.opacity(0.15))
            )
            .foregroundStyle(badgeColor)
    }

    private var badgeColor: Color {
        switch source {
        case .curated: .blue
        case .gutenberg: .orange
        case .generated: .purple
        }
    }
}
