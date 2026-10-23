
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
                    PodcastPlayerView(
                        episode: episode,
                        playback: playback
                    )
                }
            }
        }
        .overlay {
            if playback.isLoading {
                loadingOverlay
            }
        }
        .alert(
            "팟캐스트 오류",
            isPresented: Binding(
                get: { playback.errorMessage != nil },
                set: { newValue in
                    if !newValue {
                        playback.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {
                playback.errorMessage = nil
            }
        } message: {
            Text(playback.errorMessage ?? "")
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(LingcastColor.accent)

                Text("팟캐스트를 준비하고 있어요")
                    .font(.headline)

                Text("AI가 뉴스 음성을 생성하는 중입니다.")
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
            }
            .padding(28)
            .background(
                LingcastColor.background,
                in: RoundedRectangle(cornerRadius: 20)
            )
        }
    }

    @ViewBuilder
    private func tabContent<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if playback.episode != nil,
                   playback.podcastDetail != nil {
                    MiniPlayerView(playback: playback)
                }
            }
    }
}

#Preview {
    MainTabView()
}

