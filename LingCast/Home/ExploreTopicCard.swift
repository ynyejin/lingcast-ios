//
//  ExploreTopicCard.swift
//  LingCast
//
//  Created by 윤예진 on 9/18/26.
//

import SwiftUI

struct ExploreTopicCard: View {
    let topic: HomeTopic

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            HomePlaceholderArtwork(style: topic.artwork)

            LinearGradient(
                colors: [
                    .clear,
                    LingcastColor.darkSurface.opacity(0.55)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            Text(topic.name)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(16)
        }
        .frame(height: 132)
        .clipShape(RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous))
    }
}

#Preview {
    ExploreTopicCard(topic: HomeMockData.topics[0])
        .padding()
        .background(LingcastColor.background)
}
