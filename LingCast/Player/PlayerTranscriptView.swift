//
//  PlayerTranscriptView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

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
                    proxy.scrollTo(currentIndex, anchor: .center)
                }
            }
            .background(LingcastColor.darkSurface.ignoresSafeArea())
            .navigationTitle("Transcript")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(LingcastColor.darkSurface, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.large])
    }

    private func transcriptRow(_ sentence: TranscriptSentence) -> some View {
        let isCurrent = sentence.id == currentIndex

        return VStack(alignment: .leading, spacing: 10) {
            CaptionSentenceText(
                sentence: sentence,
                isActive: isCurrent,
                showsSpokenWord: isCurrent,
                font: .title3,
                onWordTap: { word in
                    onWordTap(PlayerMockData.definition(for: word, contextSentence: sentence.english))
                }
            )

            if expandedSentenceID == sentence.id {
                Text(sentence.korean)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isCurrent ? LingcastColor.accent.opacity(0.16) : Color.white.opacity(0.05),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectSentence(sentence.id)
            withAnimation(.easeInOut(duration: 0.2)) {
                expandedSentenceID = expandedSentenceID == sentence.id ? nil : sentence.id
            }
        }
    }
}
