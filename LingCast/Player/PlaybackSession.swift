//
//  PlaybackSession.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import Foundation
import Observation

@Observable
final class PlaybackSession {
    var episode: PlayableEpisode?
    var isPlaying = false
    var progress = 0.34
    var isPlayerPresented = false

    func play(_ episode: PlayableEpisode) {
        self.episode = episode
        isPlaying = true
        isPlayerPresented = true
        progress = 0.34
    }

    func stop() {
        episode = nil
        isPlaying = false
        progress = 0
        isPlayerPresented = false
    }
}
