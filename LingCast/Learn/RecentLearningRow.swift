//
//  RecentLearningRow.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct RecentLearningRow: View {
    let item: RecentLearningItem

    var body: some View {
        HStack(spacing: 14) {
            artwork

            VStack(alignment: .leading, spacing: 6) {
                Text("\(item.category) · \(item.level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(0.4)
                    .foregroundStyle(LingcastColor.secondaryText)

                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(statusText)
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
            }

            Spacer(minLength: 8)

            trailingAction
        }
        .padding(16)
        .background(
            LingcastColor.cardSurface,
            in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous)
        )
    }

    private var artwork: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(artworkGradient)
            .frame(width: 56, height: 56)
            .overlay {
                Text(item.artworkLabel)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
    }

    private var artworkGradient: LinearGradient {
        switch item.category {
        case "WORLD":
            return LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.22, blue: 0.42),
                    Color(red: 0.42, green: 0.32, blue: 0.58)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [
                    Color(red: 0.22, green: 0.42, blue: 0.52),
                    Color(red: 0.28, green: 0.52, blue: 0.62)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var statusText: String {
        switch item.status {
        case .completed(let quizScore):
            return "청취 완료 · 퀴즈 \(quizScore)"
        case .inProgress(let percent):
            return "청취 \(percent)% · 이어 듣기"
        }
    }

    @ViewBuilder
    private var trailingAction: some View {
        switch item.status {
        case .completed:
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(LingcastColor.secondaryText)
        case .inProgress:
            Button(action: {}) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LingcastColor.accent)
                    .offset(x: 1)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("이어 듣기")
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(LearnMockData.recent) { item in
            RecentLearningRow(item: item)
        }
    }
    .padding()
    .background(LingcastColor.background)
}
