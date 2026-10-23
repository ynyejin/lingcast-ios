import Foundation

final class NewsService {
    static let shared = NewsService()

    private init() {}

    // 카테고리별 실제 뉴스 목록 조회
    func getNews(category: String = "전체") async throws -> NewsListResponse {
        var endpoint = "/api/v1/news"

        if category != "전체" {
            guard let encodedCategory = category.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed
            ) else {
                throw URLError(.badURL)
            }

            endpoint += "?category=\(encodedCategory)"
        }

        let response: APIResponse<NewsListResponse> =
            try await APIClient.shared.request(
                endpoint: endpoint
            )

        return response.data
    }

    // 사용자 추천 뉴스 조회
    func getRecommendedNews() async throws -> NewsListResponse {
        let response: APIResponse<NewsListResponse> =
            try await APIClient.shared.request(
                endpoint: "/api/v1/news/recommendations"
            )

        return response.data
    }
}
