//
//  PlayableEpisode.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct PlayableEpisode: Identifiable, Hashable {
    let id: String
    let category: String
    let headline: String
    let durationMinutes: Int
    let description: String
    let artwork: HomeArtworkStyle

    init(
        id: String,
        category: String,
        headline: String,
        durationMinutes: Int,
        description: String,
        artwork: HomeArtworkStyle
    ) {
        self.id = id
        self.category = category
        self.headline = headline
        self.durationMinutes = durationMinutes
        self.description = description
        self.artwork = artwork
    }

    init(_ story: HomeStory) {
        self.init(
            id: story.id,
            category: story.category,
            headline: story.headline,
            durationMinutes: story.durationMinutes,
            description: story.description,
            artwork: story.artwork
        )
    }

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

    init(_ item: RecentLearningItem) {
        self.init(
            id: item.id,
            category: item.category,
            headline: item.title,
            durationMinutes: 6,
            description: "",
            artwork: item.category == "WORLD" ? .worldNews : .technology
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
