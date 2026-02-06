import SwiftUI

struct NarratorAvatarView: View {
    let character: NarratorCharacter
    let isSpeaking: Bool
    let playbackState: SpeechService.PlaybackState
    let onPlayPause: () -> Void
    let onStop: () -> Void

    @State private var floatOffset: CGFloat = 0
    @State private var speakScale: CGFloat = 1.0
    @State private var isMinimized = false

    var body: some View {
        VStack(spacing: 0) {
            if isMinimized {
                minimizedView
            } else {
                expandedView
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                floatOffset = -6
            }
        }
        .onChange(of: isSpeaking) { _, speaking in
            if speaking {
                withAnimation(
                    .easeInOut(duration: 0.4)
                    .repeatForever(autoreverses: true)
                ) {
                    speakScale = 1.12
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    speakScale = 1.0
                }
            }
        }
    }

    // MARK: - Expanded

    private var expandedView: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isMinimized = true
                    }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }

            Text(character.emoji)
                .font(.system(size: 64))
                .scaleEffect(speakScale)
                .offset(y: floatOffset)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            Text(character.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)

            HStack(spacing: 20) {
                Button(action: onStop) {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Stop narration")

                Button(action: onPlayPause) {
                    Image(systemName: playbackState == .playing
                        ? "pause.circle.fill"
                        : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.indigo)
                }
                .accessibilityLabel(
                    playbackState == .playing ? "Pause" : "Resume"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .frame(width: 160)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Minimized

    private var minimizedView: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isMinimized = false
            }
        } label: {
            HStack(spacing: 8) {
                Text(character.emoji)
                    .font(.system(size: 28))
                    .scaleEffect(speakScale)
                    .offset(y: floatOffset)

                if playbackState == .playing {
                    Circle()
                        .fill(.indigo)
                        .frame(width: 8, height: 8)
                        .opacity(isSpeaking ? 1 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.5).repeatForever(),
                            value: isSpeaking
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
