import SwiftUI

struct NewsFeedStoryCard: View {
    let story: HomeStory

    @Environment(\.playEpisode) private var playEpisode

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

            // 뉴스 상세 화면 이동
            if let newsId = Int64(story.id) {
                NavigationLink {
                    NewsDetailView(newsId: newsId)
                } label: {
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

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
                .allowsHitTesting(false) 

                Spacer(minLength: 8)

                LingcastPlayButton(size: 44) {
                    playEpisode(PlayableEpisode(story))
                }
            }
            .padding(16)
        }
        .frame(height: 260)
        .clipShape(
            RoundedRectangle(
                cornerRadius: HomeLayout.cardCornerRadius,
                style: .continuous
            )
        )
    }
}

#Preview {
    NavigationStack {
        NewsFeedStoryCard(
            story: HomeMockData.feedStories(for: "IT")[0]
        )
        .padding()
        .background(LingcastColor.background)
    }
}
