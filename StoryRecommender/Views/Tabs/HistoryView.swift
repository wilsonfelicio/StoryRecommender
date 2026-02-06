import SwiftUI

struct HistoryView: View {
    @Environment(HistoryViewModel.self) private var historyVM
    @State private var showClearConfirmation = false

    var body: some View {
        Group {
            if historyVM.isEmpty {
                EmptyStateView(
                    emoji: "📚",
                    title: "No Stories Read Yet",
                    message: "Stories you read will appear here so you can easily find them again."
                )
            } else {
                List {
                    ForEach(historyVM.entries) { entry in
                        NavigationLink {
                            StoryReaderView(storyId: entry.storyId)
                        } label: {
                            HistoryRowView(entry: entry)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !historyVM.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        showClearConfirmation = true
                    }
                }
            }
        }
        .confirmationDialog("Clear Reading History?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) {
                historyVM.clearHistory()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all reading history. This action cannot be undone.")
        }
    }
}

struct HistoryRowView: View {
    let entry: HistoryEntry

    var body: some View {
        HStack(spacing: 14) {
            Text(entry.coverEmoji)
                .font(.system(size: 36))
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray6))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(entry.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    SourceBadge(source: entry.source)
                    Text(RelativeDateFormatter.string(from: entry.lastReadAt))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
