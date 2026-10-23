
import Foundation

final class PodcastService {

    static let shared = PodcastService()

    private init() {}

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
}

