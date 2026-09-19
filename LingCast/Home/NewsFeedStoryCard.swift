//
//  NewsFeedStoryCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct NewsFeedStoryCard: View {
    let story: HomeStory

    var body: some View {
        ZStack(alignment: .bottom) {
            HomePlaceholderArtwork(style: story.artwork)

            LinearGradient(
                colors: [
                    .clear,
                    LingcastColor.darkSurface.opacity(0.78)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(story.metadataText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.78))

                    Text(story.headline)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                LingcastPlayButton(size: 44)
            }
            .padding(16)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous))
    }
}

#Preview {
    NewsFeedStoryCard(story: HomeMockData.feedStories(for: "IT")[0])
        .padding()
        .background(LingcastColor.background)
}
