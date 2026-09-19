//
//  FeaturedStoryCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct FeaturedStoryCard: View {
    let story: HomeStory

    var body: some View {
        ZStack(alignment: .bottom) {
            HomePlaceholderArtwork(style: story.artwork)

            LinearGradient(
                colors: [
                    .clear,
                    .clear,
                    LingcastColor.darkSurface.opacity(0.82)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(story.metadataText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.78))

                    Text(story.headline)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)

                    if !story.description.isEmpty {
                        Text(story.description)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.78))
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: 8)

                LingcastPlayButton(size: 52)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: HomeLayout.featuredCornerRadius, style: .continuous))
    }
}

#Preview {
    FeaturedStoryCard(story: HomeMockData.featuredStories(for: "전체")[0])
        .frame(height: 360)
        .padding()
        .background(LingcastColor.background)
}
