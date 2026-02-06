import Foundation
import AVFoundation

@Observable
final class SpeechService: NSObject {

    enum PlaybackState {
        case idle
        case playing
        case paused
    }

    var playbackState: PlaybackState = .idle
    var currentSentenceIndex: Int = 0
    var totalSentences: Int = 0

    var isSpeaking: Bool {
        playbackState == .playing
    }

    // MARK: - Private

    private let synthesizer = AVSpeechSynthesizer()
    private var sentences: [String] = []
    private var currentCharacter: NarratorCharacter = .bravePuppy
    private var currentIndex: Int = 0

    override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    // MARK: - Public API

    func startReading(text: String, character: NarratorCharacter) {
        stop()
        currentCharacter = character
        sentences = splitIntoSentences(text)
        totalSentences = sentences.count
        currentIndex = 0

        guard !sentences.isEmpty else { return }
        speakSentence(at: 0)
    }

    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            playbackState = .paused
        }
    }

    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            playbackState = .playing
        }
    }

    func togglePlayPause() {
        switch playbackState {
        case .playing: pause()
        case .paused: resume()
        case .idle: break
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        playbackState = .idle
        currentSentenceIndex = 0
        sentences = []
    }

    // MARK: - Private Helpers

    private func splitIntoSentences(_ text: String) -> [String] {
        var result: [String] = []
        text.enumerateSubstrings(
            in: text.startIndex...,
            options: .bySentences
        ) { substring, _, _, _ in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines),
               !sentence.isEmpty {
                result.append(sentence)
            }
        }
        return result
    }

    private func speakSentence(at index: Int) {
        guard index < sentences.count else {
            playbackState = .idle
            return
        }

        currentIndex = index
        currentSentenceIndex = index

        let utterance = AVSpeechUtterance(string: sentences[index])

        // Use pt-BR voice with fallback chain
        utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
            ?? AVSpeechSynthesisVoice(language: "pt")
            ?? AVSpeechSynthesisVoice(language: "en-US")

        // Apply character personality
        utterance.pitchMultiplier = currentCharacter.voicePitch
        utterance.rate = currentCharacter.voiceRate

        // Natural pauses between sentences
        utterance.preUtteranceDelay = index == 0 ? 0.3 : 0.15
        utterance.postUtteranceDelay = 0.1

        playbackState = .playing
        synthesizer.speak(utterance)
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        let nextIndex = currentIndex + 1
        if nextIndex < sentences.count {
            speakSentence(at: nextIndex)
        } else {
            playbackState = .idle
        }
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didPause utterance: AVSpeechUtterance
    ) {
        playbackState = .paused
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didContinue utterance: AVSpeechUtterance
    ) {
        playbackState = .playing
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        playbackState = .idle
    }
}
