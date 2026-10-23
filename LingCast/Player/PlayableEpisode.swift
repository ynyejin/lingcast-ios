
import SwiftUI

struct PlayableEpisode: Identifiable, Hashable {
    let id: String
    let newsId: Int64?
    let category: String
    let headline: String
    let durationMinutes: Int
    let description: String
    let artwork: HomeArtworkStyle

    init(
        id: String,
        newsId: Int64? = nil,
        category: String,
        headline: String,
        durationMinutes: Int,
        description: String,
        artwork: HomeArtworkStyle
    ) {
        self.id = id
        self.newsId = newsId
        self.category = category
        self.headline = headline
        self.durationMinutes = durationMinutes
        self.description = description
        self.artwork = artwork
    }

    // Home에서 선택한 뉴스
    init(_ story: HomeStory) {
        self.init(
            id: story.id,
            newsId: Int64(story.id),
            category: story.category,
            headline: story.headline,
            durationMinutes: story.durationMinutes,
            description: story.description,
            artwork: story.artwork
        )
    }

    // Saved 콘텐츠 (현재 Mock)
    init(_ story: SavedStory) {
        self.init(
            id: story.id,
            category: story.category,
            headline: story.title,
            durationMinutes: story.durationMinutes,
            description: "",
            artwork: story.artwork
        )
    }

    // Learn 콘텐츠 (현재 Mock)
    init(_ item: RecentLearningItem) {
        self.init(
            id: item.id,
            category: item.category,
            headline: item.title,
            durationMinutes: item.durationMinutes,
            description: "",
            artwork: item.artwork
        )
    }
}

private struct PlayEpisodeKey: EnvironmentKey {
    static let defaultValue: (PlayableEpisode) -> Void = { _ in }
}

extension EnvironmentValues {
    var playEpisode: (PlayableEpisode) -> Void {
        get { self[PlayEpisodeKey.self] }
        set { self[PlayEpisodeKey.self] = newValue }
    }
}

