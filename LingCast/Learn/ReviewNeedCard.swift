//
//  ReviewNeedCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct ReviewNeedCard: View {
    let prompt: ReviewPrompt

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Image(systemName: prompt.iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconBackground, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(prompt.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: {}) {
                    HStack(spacing: 2) {
                        Text(prompt.actionTitle)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 164, alignment: .topLeading)
        .background(
            LingcastColor.cardSurface,
            in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous)
        )
    }

    private var iconColor: Color {
        prompt.usesWarmAccent
            ? Color(red: 0.78, green: 0.62, blue: 0.22)
            : LingcastColor.accent
    }

    private var iconBackground: Color {
        prompt.usesWarmAccent
            ? Color(red: 0.98, green: 0.95, blue: 0.86)
            : LingcastColor.accent.opacity(0.12)
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(LearnMockData.reviewPrompts) { prompt in
            ReviewNeedCard(prompt: prompt)
        }
    }
    .padding()
    .background(LingcastColor.background)
}
