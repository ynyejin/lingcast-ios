//
//  CaptionSentenceText.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct CaptionSentenceText: View {
    let sentence: TranscriptSentence
    var isActive: Bool
    var showsSpokenWord: Bool
    var font: Font = .title3
    var onWordTap: (String) -> Void

    var body: some View {
        WrappingHStack(alignment: .leading, spacing: 6) {
            ForEach(Array(tokens.enumerated()), id: \.offset) { _, token in
                if token.isTappable {
                    Button {
                        onWordTap(token.lookup)
                    } label: {
                        Text(token.display)
                            .underline()
                            .foregroundStyle(color(for: token))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(token.display)
                        .foregroundStyle(color(for: token))
                }
            }
        }
        .font(font.weight(.semibold))
    }

    private var tokens: [CaptionToken] {
        sentence.english.split(separator: " ", omittingEmptySubsequences: false).map { part in
            let display = String(part)
            let lookup = display.trimmingCharacters(in: .punctuationCharacters)
            let isTappable = sentence.vocabulary.contains { $0.caseInsensitiveCompare(lookup) == .orderedSame }
            return CaptionToken(display: display, lookup: lookup, isTappable: isTappable)
        }
    }

    private func color(for token: CaptionToken) -> Color {
        if showsSpokenWord, token.lookup.caseInsensitiveCompare(sentence.spokenWord) == .orderedSame {
            return LingcastColor.accent
        }
        if isActive {
            return .white
        }
        return .white.opacity(0.55)
    }
}

private struct CaptionToken {
    let display: String
    let lookup: String
    let isTappable: Bool
}

private struct WrappingHStack: Layout {
    var alignment: Alignment = .leading
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        for (index, point) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var width: CGFloat = 0
        var positions: [CGPoint] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + 6
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            width = max(width, x - spacing)
        }

        return (CGSize(width: width, height: y + rowHeight), positions)
    }
}
