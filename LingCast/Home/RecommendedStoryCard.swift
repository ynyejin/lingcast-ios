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
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .allowsHitTesting(false)

                Spacer(minLength: 8)

                LingcastPlayButton(size: 36) {
                    playEpisode(PlayableEpisode(story))
                }
            }
            .padding(16)
        }
        .frame(height: 250)
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
        RecommendedStoryCard(
            story: HomeMockData.recommended[0]
        )
        .frame(width: 280)
        .padding()
        .background(LingcastColor.background)
    }
}
