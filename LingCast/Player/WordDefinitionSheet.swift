//
//  WordDefinitionSheet.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct WordDefinitionSheet: View {
    let definition: WordDefinition
    @State private var isSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Capsule()
                .fill(Color.white.opacity(0.28))
                .frame(width: 40, height: 4)
                .frame(maxWidth: .infinity)

            Text(definition.word)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(definition.koreanMeaning)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(LingcastColor.accent)

            Text(definition.englishExplanation)
                .font(.body)
                .foregroundStyle(.white.opacity(0.86))

            VStack(alignment: .leading, spacing: 8) {
                Text("문맥")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.5))

                Text(definition.contextSentence)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.78))
                    .italic()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button {
                isSaved = true
            } label: {
                Text(isSaved ? "저장됨" : "Save word")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LingcastColor.accent, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(isSaved)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LingcastColor.darkSurface)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}
