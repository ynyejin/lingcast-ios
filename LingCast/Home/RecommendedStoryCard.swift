//
//  RecommendedStoryCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct RecommendedStoryCard: View {
    let story: HomeStory
    @Environment(\.playEpisode) private var playEpisode

    var body: some View {
        ZStack(alignment: .bottom) {
            HomePlaceholderArtwork(style: story.artwork)

            LinearGradient(
                colors: [
                    .clear,
                    LingcastColor.darkSurface.opacity(0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(story.metadataText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.78))

                    Text(story.headline)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                LingcastPlayButton(size: 36) {
                    playEpisode(PlayableEpisode(story))
                }
            }
            .padding(16)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous))
    }
}

#Preview {
    RecommendedStoryCard(story: HomeMockData.recommended[0])
        .frame(width: 280)
        .padding()
        .background(LingcastColor.background)
}
