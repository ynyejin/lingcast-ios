//
//  PodcastPlayerView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct PodcastPlayerView: View {

    let episode: PlayableEpisode

    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false
    @State private var captionsEnabled = true
    @State private var currentIndex = 1
    @State private var showingTranscript = false
    @State private var selectedWord: WordDefinition?

    private var sentences: [TranscriptSentence] {
        PlayerMockData.sentences(for: episode)
    }

    private var currentSentence: TranscriptSentence {
        sentences[min(currentIndex, sentences.count - 1)]
    }
    
    private var previousSentence: TranscriptSentence? {
        guard currentIndex > 0 else { return nil }
        return sentences[currentIndex - 1]
    }

    private var nextSentence: TranscriptSentence? {
        guard currentIndex < sentences.count - 1 else { return nil }
        return sentences[currentIndex + 1]
    }

    private var progress: Double {
        guard sentences.count > 1 else { return 0 }
        return Double(currentIndex) / Double(sentences.count - 1)
    }

    private var elapsedText: String {
        let total = episode.durationMinutes * 60
        let elapsed = Int(progress * Double(total))
        return timeString(elapsed)
    }

    private var durationText: String {
        timeString(episode.durationMinutes * 60)
    }

    var body: some View {
        ZStack {
            background

            VStack(alignment: .leading, spacing: 28) {
                header

                if captionsEnabled {
                    captionBlock
                } else {
                    Spacer(minLength: 80)
                }

                Spacer()

                controls
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("뒤로가기")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    captionsEnabled.toggle()
                } label: {
                    Image(
                        systemName: captionsEnabled
                            ? "captions.bubble.fill"
                            : "captions.bubble"
                    )
                    .font(.body.weight(.semibold))
                }
                .accessibilityLabel(
                    captionsEnabled ? "자막 끄기" : "자막 켜기"
                )
            }
        }
        .sheet(isPresented: $showingTranscript) {
            PlayerTranscriptView(
                sentences: sentences,
                currentIndex: currentIndex,
                onSelectSentence: { currentIndex = $0 },
                onWordTap: { selectedWord = $0 }
            )
        }
        .sheet(item: $selectedWord) { word in
            WordDefinitionSheet(definition: word)
        }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            HomePlaceholderArtwork(style: episode.artwork)
                .blur(radius: 28)
                .opacity(0.45)

            LinearGradient(
                colors: [
                    LingcastColor.darkSurface.opacity(0.55),
                    LingcastColor.darkSurface.opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            HomePlaceholderArtwork(style: episode.artwork)
                .frame(width: 56, height: 56)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14,
                        style: .continuous
                    )
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(episode.headline)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text("\(episode.durationMinutes) MIN LISTEN")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Caption

    private var captionBlock: some View {
        VStack(alignment: .leading, spacing: 18) {

            // 이전 문장
            if let previousSentence {
                Text(previousSentence.english)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.32))
                    .lineLimit(2)
            }

            // 현재 재생 문장
            CaptionSentenceText(
                sentence: currentSentence,
                isActive: true,
                showsSpokenWord: true,
                font: .title,
                onWordTap: { word in
                    selectedWord = PlayerMockData.definition(
                        for: word,
                        contextSentence: currentSentence.english
                    )
                }
            )

            // 다음 문장
            if let nextSentence {
                Text(nextSentence.english)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.32))
                    .lineLimit(2)
            }

            Button {
                showingTranscript = true
            } label: {
                Text("탭해서 전체 자막 보기")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(spacing: 18) {
            PlayerWaveformView(progress: progress) { newProgress in
                let maxIndex = max(sentences.count - 1, 0)

                currentIndex = min(
                    max(
                        Int(
                            (newProgress * Double(maxIndex))
                                .rounded()
                        ),
                        0
                    ),
                    maxIndex
                )
            }

            HStack {
                Text(elapsedText)
                    .foregroundStyle(.white)

                Spacer()

                Text(durationText)
                    .foregroundStyle(.white.opacity(0.35))
            }
            .font(.subheadline.monospacedDigit().weight(.medium))

            HStack(spacing: 36) {
                Button {
                    currentIndex = max(currentIndex - 1, 0)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Button {
                    isPlaying.toggle()
                } label: {
                    Image(
                        systemName: isPlaying
                            ? "pause.fill"
                            : "play.fill"
                    )
                    .font(.title.weight(.bold))
                    .foregroundStyle(LingcastColor.darkSurface)
                    .offset(x: isPlaying ? 0 : 2)
                    .frame(width: 76, height: 76)
                    .background(.white, in: Circle())
                }

                Button {
                    currentIndex = min(
                        currentIndex + 1,
                        sentences.count - 1
                    )
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Helpers

    private func timeString(_ seconds: Int) -> String {
        String(
            format: "%02d:%02d",
            seconds / 60,
            seconds % 60
        )
    }
}

// MARK: - Waveform

private struct PlayerWaveformView: View {

    let progress: Double
    var onSeek: (Double) -> Void

    private let samples: [CGFloat] = [
        0.25, 0.4, 0.55, 0.35, 0.7, 0.5, 0.9, 0.45, 0.62, 0.3,
        0.8, 0.52, 0.38, 0.74, 0.46, 0.88, 0.33, 0.6, 0.42, 0.7,
        0.28, 0.5, 0.64, 0.4, 0.78, 0.48, 0.36, 0.58, 0.44, 0.66
    ]

    var body: some View {
        GeometryReader { proxy in
            let barCount = samples.count
            let spacing: CGFloat = 3
            let barWidth = max(
                (proxy.size.width - spacing * CGFloat(barCount - 1))
                / CGFloat(barCount),
                2
            )

            HStack(alignment: .center, spacing: spacing) {
                ForEach(samples.indices, id: \.self) { index in
                    Capsule()
                        .fill(
                            Double(index) / Double(barCount - 1) <= progress
                                ? LingcastColor.accent
                                : Color.white.opacity(0.22)
                        )
                        .frame(
                            width: barWidth,
                            height: max(
                                proxy.size.height * samples[index],
                                6
                            )
                        )
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let ratio = min(
                            max(value.location.x / proxy.size.width, 0),
                            1
                        )

                        onSeek(ratio)
                    }
            )
        }
        .frame(height: 48)
    }
}
    
    #Preview {
        NavigationStack {
            PodcastPlayerView(
                episode: PlayableEpisode(
                    HomeMockData.recommended[0]
                )
            )
        }
    }
