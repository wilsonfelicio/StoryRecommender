import SwiftUI

struct StreamingStoryView: View {
    let text: String
    @State private var showCursor = true

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("✨")
                            .font(.system(size: 48))
                        Text("Writing your story...")
                            .font(.title3.weight(.semibold))
                    }
                    .padding(.top, 8)

                    // Paragraphs
                    VStack(alignment: .leading, spacing: 12) {
                        let paragraphs = text.components(separatedBy: "\n\n").filter { !$0.isEmpty }
                        ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                            HStack(alignment: .bottom, spacing: 0) {
                                Text(paragraph)
                                    .font(.system(size: 18, design: .serif))
                                    .lineSpacing(9)

                                if index == paragraphs.count - 1 {
                                    cursorView
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Bounce dots
                    HStack(spacing: 6) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color.indigo.opacity(0.6))
                                .frame(width: 8, height: 8)
                                .offset(y: showCursor ? -4 : 4)
                                .animation(
                                    .easeInOut(duration: 0.5)
                                    .repeatForever()
                                    .delay(Double(i) * 0.15),
                                    value: showCursor
                                )
                        }
                    }
                    .padding(.vertical, 12)
                    .id("bottom")
                }
                .padding(.bottom, 40)
            }
            .onChange(of: text) {
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onAppear {
                showCursor = true
            }
        }
    }

    private var cursorView: some View {
        Rectangle()
            .fill(Color.indigo)
            .frame(width: 2, height: 20)
            .opacity(showCursor ? 1 : 0)
            .animation(.easeInOut(duration: 0.6).repeatForever(), value: showCursor)
            .padding(.leading, 2)
    }
}
