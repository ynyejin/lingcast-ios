//
//  MainTabView.swift
//  LingCast
//
//  Created by 윤예진 on 9/11/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var playback = PlaybackSession()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                tabContent {
                    HomeView()
                }
            }
            Tab("Learn", systemImage: "book") {
                tabContent {
                    LearnView()
                }
            }
            Tab("Saved", systemImage: "bookmark") {
                tabContent {
                    SavedView()
                }
            }
            Tab("Profile", systemImage: "person") {
                tabContent {
                    ProfileView()
                }
            }
        }
        .environment(\.playEpisode) { episode in
            playback.play(episode)
        }
        .fullScreenCover(isPresented: $playback.isPlayerPresented) {
            if let episode = playback.episode {
                NavigationStack {
                    PodcastPlayerView(episode: episode)
                }
            }
        }
    }

    @ViewBuilder
    private func tabContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if playback.episode != nil {
                    MiniPlayerView(playback: playback)
                }
            }
    }
}

#Preview {
    MainTabView()
}
