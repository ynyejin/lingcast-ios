//
//  SavedWordsList.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct SavedWordsList: View {
    let words: [SavedWord]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(words.enumerated()), id: \.element.id) { index, word in
                SavedWordRow(word: word)

                if index < words.count - 1 {
                    Divider()
                        .overlay(LingcastColor.secondaryText.opacity(0.16))
                        .padding(.leading, 20)
                }
            }
        }
        .background(
            LingcastColor.cardSurface,
            in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous)
        )
    }
}

private struct SavedWordRow: View {
    let word: SavedWord

    var body: some View {
        Button(action: {}) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(word.term)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(LingcastColor.primaryText)

                    Text(word.meaning)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(LingcastColor.accent)

                    Text(word.definition)
                        .font(.subheadline)
                        .italic()
                        .foregroundStyle(LingcastColor.secondaryText)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(LingcastColor.secondaryText)
            }
            .padding(20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(word.term), \(word.meaning)")
    }
}

#Preview {
    SavedWordsList(words: Array(SavedMockData.words.prefix(3)))
        .padding()
        .background(LingcastColor.background)
}
