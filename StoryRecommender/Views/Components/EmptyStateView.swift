import SwiftUI

struct EmptyStateView: View {
    let emoji: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 64))
            Text(title)
                .font(.title3.weight(.semibold))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
