
import SwiftUI

struct PodcastPlayerView: View {

    let episode: PlayableEpisode
    @Bindable var playback: PlaybackSession

    @State private var captionsEnabled = true
    @State private var showingTranscript = false
    @State private var selectedWord: WordDefinition?

    // MARK: - WhisperX 자막

    private var sentences: [TranscriptSentence] {
        playback.transcriptSentences.map {
            $0.toTranscriptSentence()
        }
    }

    private var safeCurrentIndex: Int {
        let items = playback.transcriptSentences

        guard !items.isEmpty else { return 0 }

        let currentMs = Int64(playback.currentTime * 1000)

        if let index = items.firstIndex(where: {
            currentMs >= $0.startMs &&
            currentMs < $0.endMs
        }) {
            return index
        }

        // 문장 사이의 공백에서는 직전 문장 유지
        if let index = items.lastIndex(where: {
            currentMs >= $0.startMs
        }) {
            return index
        }

        return 0
    }

    private var currentSentence: TranscriptSentence? {
        guard sentences.indices.contains(safeCurrentIndex) else {
            return nil
        }

        return sentences[safeCurrentIndex]
    }

    private var previousSentence: TranscriptSentence? {
        let index = safeCurrentIndex - 1

        guard sentences.indices.contains(index) else {
            return nil
        }

        return sentences[index]
    }

    private var nextSentence: TranscriptSentence? {
        let index = safeCurrentIndex + 1

        guard sentences.indices.contains(index) else {
            return nil
        }

        return sentences[index]
    }

    private var elapsedText: String {
        timeString(Int(playback.currentTime))
    }

    private var durationText: String {
        timeString(Int(playback.duration))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            background

            VStack(alignment: .leading, spacing: 0) {
                header

                Spacer(minLength: 12)

                if captionsEnabled {
                    captionBlock
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                        .clipped()
                } else {
                    Spacer()
                }

                controls
                    .padding(.top, 20)
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    playback.isPlayerPresented = false
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("뒤로가기")
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        captionsEnabled.toggle()
                    }
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
                currentIndex: safeCurrentIndex,
                onSelectSentence: { sentenceIndex in
                    guard let sentence =
                        playback.transcriptSentences.first(
                            where: {
                                $0.sentenceIndex == sentenceIndex
                            }
                        )
                    else {
                        return
                    }

                    playback.seek(
                        to: Double(sentence.startMs) / 1000.0
                    )
                },
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
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: 0)

                ZStack(alignment: .leading) {
                    if sentences.isEmpty {
                        Text(
                            playback.isTranscriptLoading
                                ? "자막을 준비하고 있습니다..."
                                : (playback.transcriptErrorMessage
                                    ?? "표시할 자막이 없습니다.")
                        )
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                    } else {
                        captionPage
                            .id(currentSentence?.id ?? -1)
                            .transition(
                                .asymmetric(
                                    insertion: .offset(y: 35)
                                        .combined(with: .opacity),
                                    removal: .offset(y: -35)
                                        .combined(with: .opacity)
                                )
                            )
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: min(
                        geometry.size.height * 0.85,
                        420
                    ),
                    alignment: .center
                )
                .clipped()
                .animation(
                    .easeInOut(duration: 0.45),
                    value: safeCurrentIndex
                )

                Spacer(minLength: 0)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
    }

    private var captionPage: some View {
        VStack(alignment: .leading, spacing: 18) {

            // 이전 문장
            if let previousSentence {
                Text(previousSentence.english)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.32))
                    .lineLimit(2)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }

            // 현재 문장
            if let currentSentence {
                ScrollView(.vertical) {
                    CaptionSentenceText(
                        sentence: currentSentence,
                        isActive: true,
                        showsSpokenWord: false,
                        font: .title,
                        onWordTap: { word in
                            selectedWord = PlayerMockData.definition(
                                for: word,
                                contextSentence: currentSentence.english
                            )
                        }
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
                .scrollIndicators(.hidden)
                .frame(maxHeight: 240)
            }

            // 다음 문장
            if let nextSentence {
                Text(nextSentence.english)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.32))
                    .lineLimit(2)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
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
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(spacing: 18) {

            PlayerWaveformView(progress: playback.progress) {
                newProgress in

                playback.seek(toProgress: newProgress)
            }

            HStack {
                Text(elapsedText)
                    .foregroundStyle(.white)

                Spacer()

                Text(durationText)
                    .foregroundStyle(.white.opacity(0.35))
            }
            .font(
                .subheadline
                    .monospacedDigit()
                    .weight(.medium)
            )

            HStack(spacing: 36) {

                Button {
                    playback.skip(seconds: -15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("15초 뒤로")

                Button {
                    playback.togglePlayback()
                } label: {
                    Image(
                        systemName: playback.isPlaying
                            ? "pause.fill"
                            : "play.fill"
                    )
                    .font(.title.weight(.bold))
                    .foregroundStyle(LingcastColor.darkSurface)
                    .offset(x: playback.isPlaying ? 0 : 2)
                    .frame(width: 76, height: 76)
                    .background(.white, in: Circle())
                }
                .accessibilityLabel(
                    playback.isPlaying ? "일시정지" : "재생"
                )

                Button {
                    playback.skip(seconds: 15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("15초 앞으로")
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
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
        0.25, 0.4, 0.55, 0.35, 0.7, 0.5,
        0.9, 0.45, 0.62, 0.3, 0.8, 0.52,
        0.38, 0.74, 0.46, 0.88, 0.33,
        0.6, 0.42, 0.7, 0.28, 0.5,
        0.64, 0.4, 0.78, 0.48, 0.36,
        0.58, 0.44, 0.66
    ]

    var body: some View {
        GeometryReader { proxy in
            let barCount = samples.count
            let spacing: CGFloat = 3

            let barWidth = max(
                (
                    proxy.size.width
                    - spacing * CGFloat(barCount - 1)
                ) / CGFloat(barCount),
                2
            )

            HStack(alignment: .center, spacing: spacing) {
                ForEach(samples.indices, id: \.self) { index in
                    Capsule()
                        .fill(
                            Double(index) / Double(barCount - 1)
                                <= progress
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
                        guard proxy.size.width > 0 else {
                            return
                        }

                        let ratio = min(
                            max(
                                value.location.x / proxy.size.width,
                                0
                            ),
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
            ),
            playback: PlaybackSession()
        )
    }
}

