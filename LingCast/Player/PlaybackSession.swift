
import Foundation
import Observation
import AVFoundation

@MainActor
@Observable
final class PlaybackSession {

    var episode: PlayableEpisode?
    var isPlaying = false
    var progress: Double = 0.0
    var isPlayerPresented = false

    var isLoading = false
    var errorMessage: String?
    var podcastDetail: PodcastDetailResponse?

    var currentTime: Double = 0
    var duration: Double = 0

    @ObservationIgnored
    private var player: AVPlayer?

    @ObservationIgnored
    private var timeObserver: Any?

    @ObservationIgnored
    private var endObserver: NSObjectProtocol?

    @ObservationIgnored
    private var loadingTask: Task<Void, Never>?

    // 뉴스 선택 및 팟캐스트 준비
    func play(_ episode: PlayableEpisode) {
        stop()

        self.episode = episode

        guard let newsId = episode.newsId else {
            self.episode = nil
            errorMessage = "아직 재생을 지원하지 않는 콘텐츠입니다."
            return
        }

        isLoading = true

        loadingTask = Task {
            await loadPodcast(newsId: newsId)
        }
    }

    private func loadPodcast(newsId: Int64) async {
        do {
            print("팟캐스트 생성 요청 - newsId:", newsId)

            let created = try await PodcastService.shared.createPodcast(
                newsId: newsId
            )

            try Task.checkCancellation()

            print("팟캐스트 생성 응답 - podcastId:", created.podcastId)
            print("팟캐스트 상태:", created.status)

            let detail = try await PodcastService.shared.getPodcastDetail(
                podcastId: created.podcastId
            )

            try Task.checkCancellation()

            guard detail.status == "COMPLETED" else {
                errorMessage = "팟캐스트가 아직 준비되지 않았습니다."
                isLoading = false
                episode = nil
                return
            }

            guard let audioPath = detail.audioUrl,
                  !audioPath.isEmpty else {
                errorMessage = "팟캐스트 음성 파일이 없습니다."
                isLoading = false
                episode = nil
                return
            }

            // 상대 경로를 전체 URL로 변환
            let urlString: String

            if audioPath.hasPrefix("http://") ||
               audioPath.hasPrefix("https://") {
                urlString = audioPath
            } else {
                let path = audioPath.hasPrefix("/")
                    ? audioPath
                    : "/" + audioPath

                urlString = "http://localhost:8080" + path
            }

            guard let url = URL(string: urlString) else {
                errorMessage = "오디오 주소가 올바르지 않습니다."
                isLoading = false
                episode = nil
                return
            }

            podcastDetail = detail

            setupPlayer(url: url)

            isLoading = false
            isPlayerPresented = true

            player?.play()
            isPlaying = true

            print("팟캐스트 상세 조회 성공")
            print("오디오 URL:", urlString)

        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }

            isLoading = false
            episode = nil
            errorMessage = "팟캐스트를 불러오지 못했습니다."

            print("팟캐스트 API 오류:", error)
        }
    }

    // AVPlayer 생성
    private func setupPlayer(url: URL) {
        cleanupPlayer()

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)

        player = newPlayer

        // 재생 시간 및 진행률 관찰
        timeObserver = newPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor [weak self] in
                guard let self else { return }

                let seconds = time.seconds

                if seconds.isFinite {
                    self.currentTime = max(seconds, 0)
                }

                if let item = self.player?.currentItem {
                    let total = item.duration.seconds

                    if total.isFinite && total > 0 {
                        self.duration = total
                        self.progress = min(
                            max(self.currentTime / total, 0),
                            1
                        )
                    }
                }
            }
        }

        // 재생 완료 감지
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }

                self.isPlaying = false
                self.currentTime = self.duration
                self.progress = 1.0
            }
        }
    }

    // 재생 / 일시정지
    func togglePlayback() {
        guard let player else { return }

        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            if duration > 0 && currentTime >= duration - 0.1 {
                seek(to: 0)
            }

            player.play()
            isPlaying = true
        }
    }

    // 특정 시간으로 이동
    func seek(to seconds: Double) {
        guard let player else { return }

        let target = min(max(seconds, 0), duration)

        player.seek(
            to: CMTime(
                seconds: target,
                preferredTimescale: 600
            )
        )

        currentTime = target

        if duration > 0 {
            progress = target / duration
        }
    }

    // 15초 이동
    func skip(seconds: Double) {
        seek(to: currentTime + seconds)
    }

    // 진행률로 이동
    func seek(toProgress value: Double) {
        guard duration > 0 else { return }

        let ratio = min(max(value, 0), 1)
        seek(to: duration * ratio)
    }

    // 플레이어 정리
    private func cleanupPlayer() {
        player?.pause()

        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
        }

        timeObserver = nil

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }

        endObserver = nil
        player = nil
    }

    // 재생 종료
    func stop() {
        loadingTask?.cancel()
        loadingTask = nil

        cleanupPlayer()

        episode = nil
        podcastDetail = nil

        isPlaying = false
        progress = 0
        currentTime = 0
        duration = 0

        isPlayerPresented = false
        isLoading = false
        errorMessage = nil
    }
}

