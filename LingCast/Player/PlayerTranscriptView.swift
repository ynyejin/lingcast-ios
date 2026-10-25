import SwiftUI

struct PlayerTranscriptView: View {

    let sentences: [TranscriptSentence]
    let currentIndex: Int
    var onSelectSentence: (Int) -> Void
    var onWordTap: (WordDefinition) -> Void

    @State private var expandedSentenceID: Int?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(sentences) { sentence in
                            transcriptRow(sentence)
                                .id(sentence.id)
                        }
                    }
                    .padding(20)
                }
                .onAppear {
                    if sentences.indices.contains(currentIndex) {
                        proxy.scrollTo(
                            sentences[currentIndex].id,
                            anchor: .center
                        )
                    }
                }
            }
            .background(
                LingcastColor.darkSurface.ignoresSafeArea()
            )
            .navigationTitle("Transcript")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                LingcastColor.darkSurface,
                for: .navigationBar
            )
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.large])
    }

    private func transcriptRow(
        _ sentence: TranscriptSentence
    ) -> some View {

        let isCurrent = sentences.indices.contains(currentIndex)
            && sentences[currentIndex].id == sentence.id

        return VStack(alignment: .leading, spacing: 10) {

            CaptionSentenceText(
                sentence: sentence,
                isActive: isCurrent,
                showsSpokenWord: false,
                font: .title3,
                onWordTap: { word in
                    onWordTap(
                        PlayerMockData.definition(
                            for: word,
                            contextSentence: sentence.english
                        )
                    )
                }
            )

            // 한국어 번역 보기 / 숨기기 버튼
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedSentenceID =
                        expandedSentenceID == sentence.id
                            ? nil
                            : sentence.id
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "character.book.closed")
                        .font(.caption)

                    Text(
                        expandedSentenceID == sentence.id
                            ? "번역 숨기기"
                            : "번역 보기"
                    )
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
                .foregroundStyle(.white.opacity(0.65))
            }
            .buttonStyle(.plain)

            // 번역 표시
            if expandedSentenceID == sentence.id {

                let korean = sentence.korean.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                if korean.isEmpty {
                    Text("한국어 번역을 준비하고 있습니다...")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                } else {
                    Text(korean)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }
            }
        }
        .padding(16)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            isCurrent
                ? LingcastColor.accent.opacity(0.16)
                : Color.white.opacity(0.05),
            in: RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectSentence(sentence.id)
        }
    }
}
