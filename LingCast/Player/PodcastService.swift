
import Foundation

final class PodcastService {

    static let shared = PodcastService()

    private init() {}

    // MARK: - 팟캐스트 생성 및 조회

    // 선택한 뉴스로 팟캐스트 생성 또는 기존 팟캐스트 재사용
    func createPodcast(newsId: Int64) async throws -> PodcastCreateResponse {

        let endpoint = "/api/v1/podcasts?newsId=\(newsId)"

        let response: APIResponse<PodcastCreateResponse> =
            try await APIClient.shared.request(
                endpoint: endpoint,
                method: "POST",
                timeout: 180
            )

        return response.data
    }

    // 팟캐스트 상세 정보 조회
    func getPodcastDetail(podcastId: Int64) async throws -> PodcastDetailResponse {

        let endpoint = "/api/v1/podcasts/\(podcastId)"

        let response: APIResponse<PodcastDetailResponse> =
            try await APIClient.shared.request(
                endpoint: endpoint
            )

        return response.data
    }

    // 팟캐스트 문장별 자막 조회
    func getPodcastTranscript(
        podcastId: Int64
    ) async throws -> PodcastTranscriptResponse {

        let endpoint = "/api/v1/podcasts/\(podcastId)/transcript"

        let response: APIResponse<PodcastTranscriptResponse> =
            try await APIClient.shared.request(
                endpoint: endpoint
            )

        return response.data
    }

    // MARK: - 재생 위치 및 완료 처리

    // 팟캐스트 재생 위치 저장
    func updateProgress(
        podcastId: Int64,
        progressSec: Int
    ) async throws {

        let endpoint = "/api/v1/podcasts/\(podcastId)/progress"

        let requestBody = PodcastProgressRequest(
            progressSec: max(progressSec, 0)
        )

        let body = try JSONEncoder().encode(requestBody)

        let response: PodcastActionResponse =
            try await APIClient.shared.request(
                endpoint: endpoint,
                method: "PATCH",
                body: body
            )

        guard response.success else {
            throw PodcastServiceError.requestFailed
        }
    }

    // 팟캐스트 청취 완료 처리
    func completePodcast(podcastId: Int64) async throws {

        let endpoint = "/api/v1/podcasts/\(podcastId)/complete"

        let response: PodcastActionResponse =
            try await APIClient.shared.request(
                endpoint: endpoint,
                method: "POST"
            )

        guard response.success else {
            throw PodcastServiceError.requestFailed
        }
    }

    // MARK: - 팟캐스트 학습 기록 조회

    // 내 팟캐스트 학습 기록 목록 조회
    func getPodcastHistories(
        page: Int = 0,
        size: Int = 20
    ) async throws -> PodcastHistoryPageResponse {

        let endpoint = "/api/v1/podcasts/history?page=\(page)&size=\(size)"

        let response: APIResponse<PodcastHistoryPageResponse> =
            try await APIClient.shared.request(
                endpoint: endpoint
            )

        return response.data
    }

    // 개별 팟캐스트 학습 기록 조회
    // 이어 듣기를 위한 progressSec 및 completed 확인
    func getPodcastHistory(
        podcastId: Int64
    ) async throws -> PodcastHistoryResponse {

        let endpoint = "/api/v1/podcasts/\(podcastId)/history"

        let response: APIResponse<PodcastHistoryResponse> =
            try await APIClient.shared.request(
                endpoint: endpoint
            )

        return response.data
    }
}

// MARK: - 재생 위치 저장 요청

private struct PodcastProgressRequest: Encodable {
    let progressSec: Int
}

// MARK: - 데이터가 없는 API 응답

private struct PodcastActionResponse: Decodable {
    let success: Bool
    let message: String
    let code: String?
}

// MARK: - 팟캐스트 서비스 오류

private enum PodcastServiceError: Error {
    case requestFailed
}

