
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

    // WhisperX 자막
    var transcriptSentences: [PodcastSentenceResponse] = []
    var isTranscriptLoading = false
    var transcriptErrorMessage: String?

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

    // MARK: - 팟캐스트 재생 준비

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
                throw PlaybackPreparationError.notReady
            }

            guard let audioPath = detail.audioUrl,
                  !audioPath.isEmpty else {
                throw PlaybackPreparationError.missingAudio
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
                throw PlaybackPreparationError.invalidAudioURL
            }

            podcastDetail = detail

            // 음성 생성 완료 후 WhisperX 자막 준비까지 대기
            print("음성 준비 완료 - WhisperX 자막 대기 시작")

            isTranscriptLoading = true
            transcriptErrorMessage = nil

            let sentences: [PodcastSentenceResponse]

            do {
                sentences = try await waitForTranscript(
                    podcastId: detail.podcastId
                )
            } catch {
                isTranscriptLoading = false
                throw error
            }

            try Task.checkCancellation()

            transcriptSentences = sentences
            isTranscriptLoading = false

            print("음성 및 자막 준비 완료 - 재생 시작")

            // 자막이 준비된 후 플레이어 생성 및 재생
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
            isTranscriptLoading = false
            isPlaying = false
            episode = nil

            if let preparationError = error as? PlaybackPreparationError {
                errorMessage = preparationError.localizedDescription
            } else {
                errorMessage = "팟캐스트를 불러오지 못했습니다."
            }

            print("팟캐스트 준비 오류:", error)
        }
    }

    // MARK: - WhisperX 자막 준비 대기

    private func waitForTranscript(
        podcastId: Int64
    ) async throws -> [PodcastSentenceResponse] {

        // 3초 간격, 최대 40회 조회
        // 첫 조회는 즉시 실행
        let maxAttempts = 40

        for attempt in 1...maxAttempts {
            try Task.checkCancellation()

            do {
                let response =
                    try await PodcastService.shared.getPodcastTranscript(
                        podcastId: podcastId
                    )

                try Task.checkCancellation()

                guard podcastDetail?.podcastId == podcastId else {
                    throw CancellationError()
                }

                if !response.sentences.isEmpty {
                    print(
                        "WhisperX 자막 조회 성공:",
                        response.sentences.count,
                        "개"
                    )

                    return response.sentences
                }

                print(
                    "WhisperX 자막 준비 중:",
                    attempt,
                    "/",
                    maxAttempts
                )

            } catch is CancellationError {
                throw CancellationError()

            } catch {
                print("WhisperX 자막 조회 오류:", error)
            }

            if attempt < maxAttempts {
                try await Task.sleep(for: .seconds(3))
            }
        }

        throw PlaybackPreparationError.transcriptTimeout
    }

    // MARK: - AVPlayer 생성

    private func setupPlayer(url: URL) {
        cleanupPlayer()

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)

        player = newPlayer

        timeObserver = newPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(
                seconds: 0.5,
                preferredTimescale: 600
            ),
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

    // MARK: - 재생 / 일시정지

    func togglePlayback() {
        guard let player else { return }

        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            if duration > 0 &&
                currentTime >= duration - 0.1 {
                seek(to: 0)
            }

            player.play()
            isPlaying = true
        }
    }

    // MARK: - 특정 시간으로 이동

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

    // MARK: - 15초 이동

    func skip(seconds: Double) {
        seek(to: currentTime + seconds)
    }

    // MARK: - 진행률로 이동

    func seek(toProgress value: Double) {
        guard duration > 0 else { return }

        let ratio = min(max(value, 0), 1)
        seek(to: duration * ratio)
    }

    // MARK: - 플레이어 정리

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

    // MARK: - 재생 종료

    func stop() {
        loadingTask?.cancel()
        loadingTask = nil

        cleanupPlayer()

        episode = nil
        podcastDetail = nil

        transcriptSentences = []
        isTranscriptLoading = false
        transcriptErrorMessage = nil

        isPlaying = false
        progress = 0
        currentTime = 0
        duration = 0

        isPlayerPresented = false
        isLoading = false
        errorMessage = nil
    }
}

// MARK: - 팟캐스트 준비 오류

private enum PlaybackPreparationError: LocalizedError {
    case notReady
    case missingAudio
    case invalidAudioURL
    case transcriptTimeout

    var errorDescription: String? {
        switch self {
        case .notReady:
            return "팟캐스트가 아직 준비되지 않았습니다."

        case .missingAudio:
            return "팟캐스트 음성 파일이 없습니다."

        case .invalidAudioURL:
            return "오디오 주소가 올바르지 않습니다."

        case .transcriptTimeout:
            return "자막 생성 시간이 초과되었습니다. 잠시 후 다시 시도해 주세요."
        }
    }
}

