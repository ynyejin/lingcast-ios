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

    // 한국어 번역이 준비될 때까지 별도로 조회

    @ObservationIgnored

    private var translationTask: Task<Void, Never>?

    // MARK: - 학습 기록 저장

    @ObservationIgnored

    private var progressSaveTask: Task<Void, Never>?

    @ObservationIgnored

    private var lastProgressSaveTime: Int = -1

    @ObservationIgnored

    private var isCompletingPodcast = false

    @ObservationIgnored

    private var playbackGeneration = 0

    // MARK: - 팟캐스트 재생 준비

    func play(_ episode: PlayableEpisode) {
        stop()
        self.episode = episode

        isLoading = true

        if let podcastId = episode.podcastId {
            // Learn: 기존 팟캐스트를 직접 불러온다.
            loadingTask = Task {
                await loadExistingPodcast(podcastId: podcastId)
            }
        } else if let newsId = episode.newsId {
            // Home: 기존 뉴스 기반 생성/재사용 흐름을 유지한다.
            loadingTask = Task {
                await loadPodcast(newsId: newsId)
            }
        } else {
            self.episode = nil
            isLoading = false
            errorMessage = "아직 재생을 지원하지 않는 콘텐츠입니다."
        }
    }

    private func loadPodcast(newsId: Int64) async {
        do {
            print("팟캐스트 생성 요청 - newsId:", newsId)
            let created = try await PodcastService.shared.createPodcast(newsId: newsId)
            try Task.checkCancellation()
            print("팟캐스트 생성 응답 - podcastId:", created.podcastId)
            print("팟캐스트 상태:", created.status)

            let detail = try await PodcastService.shared.getPodcastDetail(
                podcastId: created.podcastId
            )
            try Task.checkCancellation()
            try await preparePlayback(detail: detail, resumeAt: 0)
        } catch {
            handlePreparationError(error)
        }
    }

    private func loadExistingPodcast(podcastId: Int64) async {
        do {
            // 상세 정보와 개인별 청취 기록은 별도 API에서 조회한다.
            let detail = try await PodcastService.shared.getPodcastDetail(
                podcastId: podcastId
            )
            try Task.checkCancellation()

            let history = try await PodcastService.shared.getPodcastHistory(
                podcastId: podcastId
            )
            try Task.checkCancellation()

            let resumeAt = history.completed ? 0 : max(history.progressSec ?? 0, 0)
            try await preparePlayback(detail: detail, resumeAt: resumeAt)
        } catch {
            handlePreparationError(error)
        }
    }

    private func preparePlayback(
        detail: PodcastDetailResponse,
        resumeAt: Int
    ) async throws {
        try Task.checkCancellation()

        guard detail.status == "COMPLETED" else {
            throw PlaybackPreparationError.notReady
        }
        guard let audioPath = detail.audioUrl, !audioPath.isEmpty else {
            throw PlaybackPreparationError.missingAudio
        }

        let urlString: String
        if audioPath.hasPrefix("http://") || audioPath.hasPrefix("https://") {
            urlString = audioPath
        } else {
            let path = audioPath.hasPrefix("/") ? audioPath : "/" + audioPath
            urlString = "http://localhost:8080" + path
        }
        guard let url = URL(string: urlString) else {
            throw PlaybackPreparationError.invalidAudioURL
        }

        podcastDetail = detail
        isTranscriptLoading = true
        transcriptErrorMessage = nil

        // 영어 자막 준비까지 대기하는 기존 정책 유지
        let sentences = try await waitForTranscript(podcastId: detail.podcastId)
        try Task.checkCancellation()
        transcriptSentences = sentences
        isTranscriptLoading = false

        setupPlayer(url: url)

        // AVPlayerItem이 준비된 뒤에 seek해야 초기 위치가 확실하게 적용된다.
        if resumeAt > 0, let player, let item = player.currentItem {
            let assetDuration = try await item.asset.load(.duration)
            try Task.checkCancellation()
            let total = assetDuration.seconds
            let requested = Double(resumeAt)
            let target: Double
            if total.isFinite && total > 0 {
                // 끝부분에서 다시 시작할 때는 완료 처리 대신 처음부터 재생
                target = requested >= total - 0.5 ? 0 : min(requested, total)
                duration = total
            } else {
                target = requested
            }

            if target > 0 {
                await player.seek(
                    to: CMTime(seconds: target, preferredTimescale: 600)
                )
                try Task.checkCancellation()
                currentTime = target
                if duration > 0 { progress = target / duration }
            }
        }

        try Task.checkCancellation()
        isLoading = false
        isPlayerPresented = true
        player?.play()
        isPlaying = true

        // seek 완료 이후의 정확한 위치만 서버에 저장한다.
        saveProgress(force: true)

        if transcriptSentences.contains(where: {
            $0.korean == nil || $0.korean?.isEmpty == true
        }) {
            translationTask = Task { [weak self] in
                await self?.waitForTranslations(podcastId: detail.podcastId)
            }
        }
        print("팟캐스트 상세 조회 성공")
        print("오디오 URL:", urlString)
    }

    private func handlePreparationError(_ error: Error) {
        if error is CancellationError || Task.isCancelled { return }
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

    // MARK: - 한국어 번역 준비 대기

    private func waitForTranslations(podcastId: Int64) async {

        // 3초 간격으로 최대 40회 확인

        // 첫 조회는 즉시 실행

        let maxAttempts = 40

        for attempt in 1...maxAttempts {

            guard !Task.isCancelled else { return }

            // 다른 팟캐스트로 전환되었으면 종료

            guard podcastDetail?.podcastId == podcastId else {

                return

            }

            do {

                let response = try await PodcastService.shared

                    .getPodcastTranscript(podcastId: podcastId)

                guard !Task.isCancelled,

                      podcastDetail?.podcastId == podcastId else {

                    return

                }

                // 문장 수가 동일한 경우에만 업데이트

                guard !response.sentences.isEmpty,

                      response.sentences.count == transcriptSentences.count,

                      zip(response.sentences, transcriptSentences)

                        .allSatisfy({

                            $0.sentenceIndex == $1.sentenceIndex

                        }) else {

                    print("한국어 번역 조회: 자막 데이터 확인 중")

                    if attempt < maxAttempts {

                        try await Task.sleep(for: .seconds(3))

                    }

                    continue

                }

                // 영어 자막의 시간 정보는 유지하고

                // 한국어 번역이 포함된 최신 응답으로 교체

                transcriptSentences = response.sentences

                let completed = response.sentences.allSatisfy {

                    guard let korean = $0.korean else {

                        return false

                    }

                    return !korean.trimmingCharacters(

                        in: .whitespacesAndNewlines

                    ).isEmpty

                }

                if completed {

                    print(

                        "한국어 번역 조회 완료:",

                        response.sentences.count,

                        "개"

                    )

                    return

                }

                print(

                    "한국어 번역 준비 중:",

                    attempt,

                    "/",

                    maxAttempts

                )

            } catch is CancellationError {

                return

            } catch {

                print("한국어 번역 조회 오류:", error)

            }

            if attempt < maxAttempts {

                do {

                    try await Task.sleep(for: .seconds(3))

                } catch {

                    return

                }

            }

        }

        print("한국어 번역 조회 대기 종료 - 영어 자막 재생은 유지")

    }

    // MARK: - 학습 기록 저장

    private func saveProgress(force: Bool = false) {

        guard let podcastId = podcastDetail?.podcastId else {

            return

        }

        let seconds = max(Int(currentTime), 0)

        // 일반 저장은 15초 간격으로 제한

        if !force {

            guard seconds - lastProgressSaveTime >= 15 else {

                return

            }

        }

        // 동일한 위치의 중복 저장 방지

        guard seconds != lastProgressSaveTime else {

            return

        }

        let generation = playbackGeneration

        // 이전 요청이 완료된 후 새 위치를 저장

        let previousTask = progressSaveTask

        let task = Task {

            await previousTask?.value

            guard !Task.isCancelled else { return }

            do {

                try await PodcastService.shared.updateProgress(

                    podcastId: podcastId,

                    progressSec: seconds

                )

                if playbackGeneration == generation {

                    lastProgressSaveTime = seconds

                }

                print("학습 기록 저장 성공:", podcastId, seconds)

            } catch {

                print("학습 기록 저장 실패:", error)

            }

        }

        progressSaveTask = task

    }

    private func markPodcastCompleted() {

        guard let podcastId = podcastDetail?.podcastId,

              !isCompletingPodcast else {

            return

        }

        isCompletingPodcast = true

        let generation = playbackGeneration

        let finalSeconds = max(Int(duration), Int(currentTime), 0)

        let previousTask = progressSaveTask

        let task = Task {

            await previousTask?.value

            do {

                // 청취 기록이 없더라도 완료 처리할 수 있도록

                // 마지막 위치를 먼저 저장

                try await PodcastService.shared.updateProgress(

                    podcastId: podcastId,

                    progressSec: finalSeconds

                )

                try await PodcastService.shared.completePodcast(

                    podcastId: podcastId

                )

                print("팟캐스트 청취 완료 저장 성공:", podcastId)

            } catch {

                print("팟캐스트 청취 완료 저장 실패:", error)

            }

            if playbackGeneration == generation {

                isCompletingPodcast = false

            }

        }

        progressSaveTask = task

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

                    // 재생 중 15초마다 학습 기록 저장

                    if self.isPlaying {

                        self.saveProgress()

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

                self.markPodcastCompleted()

            }

        }

    }

    // MARK: - 재생 / 일시정지

    func togglePlayback() {

        guard let player else { return }

        if isPlaying {

            player.pause()

            isPlaying = false

            // 일시정지 시 현재 위치 저장

            saveProgress(force: true)

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

        // 사용자가 재생 위치를 이동하면 저장

        saveProgress(force: true)

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

        // 재생 중이었다면 마지막 위치 저장

        if podcastDetail != nil && player != nil {

            saveProgress(force: true)

        }

        // 이전 재생 세대 종료

        playbackGeneration += 1

        loadingTask?.cancel()

        loadingTask = nil

        translationTask?.cancel()

        translationTask = nil

        // 저장 작업은 취소하지 않음

        // 이미 시작한 요청이 서버에 반영되도록 유지

        progressSaveTask = nil

        lastProgressSaveTime = -1

        isCompletingPodcast = false

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

