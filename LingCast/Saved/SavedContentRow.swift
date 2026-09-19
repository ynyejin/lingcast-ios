//
//  SavedContentRow.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct SavedContentRow: View {
    let story: SavedStory
    @Environment(\.playEpisode) private var playEpisode

    var body: some View {
        HStack(spacing: 14) {
            HomePlaceholderArtwork(style: story.artwork)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text("\(story.category) · \(story.level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .tracking(0.4)
                    .foregroundStyle(LingcastColor.secondaryText)

                Text(story.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(LingcastColor.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(story.durationMinutes) min listen · 저장됨")
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
            }

            Spacer(minLength: 8)

            LingcastPlayButton(size: 40) {
                playEpisode(PlayableEpisode(story))
            }
        }
        .padding(16)
        .background(
            LingcastColor.cardSurface,
            in: RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(SavedMockData.stories) { story in
            SavedContentRow(story: story)
        }
    }
    .padding()
    .background(LingcastColor.background)
}
