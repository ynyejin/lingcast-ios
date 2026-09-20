//
//  RecentLearningHistoryRow.swift
//  LingCast
//
//  Created by 윤예진 on 9/20/26.
//

import SwiftUI

struct RecentLearningHistoryRow: View {
    let item: RecentLearningItem
    @Environment(\.playEpisode) private var playEpisode

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            HomePlaceholderArtwork(style: item.artwork)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(item.category) · \(item.durationMinutes) MIN")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(LingcastColor.secondaryText)

                Text(statusText)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)

                if let progress {
                    ProgressView(value: progress)
                        .tint(LingcastColor.accent)
                }
            }

            Spacer(minLength: 8)

            LingcastPlayButton(size: 40) {
                playEpisode(PlayableEpisode(item))
            }
        }
        .padding(16)
        .background(
            LingcastColor.cardSurface,
            in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous)
        )
    }

    private var statusText: String {
        switch item.status {
        case .completed:
            return "학습 완료"
        case .inProgress(let percent):
            return "\(percent)% 학습"
        }
    }

    private var statusColor: Color {
        switch item.status {
        case .completed:
            return LingcastColor.accent
        case .inProgress:
            return LingcastColor.secondaryText
        }
    }

    private var progress: Double? {
        switch item.status {
        case .completed:
            return nil
        case .inProgress(let percent):
            return Double(percent) / 100
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(LearnMockData.learningHistory.prefix(3)) { item in
            RecentLearningHistoryRow(item: item)
        }
    }
    .padding()
    .background(LingcastColor.background)
}
