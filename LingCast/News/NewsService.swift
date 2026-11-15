
import Foundation

final class NewsService {
    static let shared = NewsService()

    private init() {}

    // 화면 표시용 카테고리를 백엔드 카테고리로 변환
    private func apiCategory(for category: String) -> String? {
        switch category.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
        case "", "ALL", "전체":
            return nil

        case "IT", "TECH", "TECHNOLOGY":
            return "TECH"

        case "경제", "BUSINESS":
            return "BUSINESS"

        case "과학", "SCIENCE":
            return "SCIENCE"

        case "HEALTH":
            return "HEALTH"

        case "DESIGN":
            return "DESIGN"

        case "MARKETING":
            return "MARKETING"

        case "EDUCATION":
            return "EDUCATION"

        case "LAW":
            return "LAW"

        case "ENVIRONMENT":
            return "ENVIRONMENT"

        default:
            return category.uppercased()
        }
    }

    // 카테고리별 실제 뉴스 목록 조회
    func getNews(category: String = "All") async throws -> NewsListResponse {
        var endpoint = "/api/v1/news"

        if let category = apiCategory(for: category) {
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

    // 사용자 관심사 기반 추천 뉴스 조회
    func getRecommendedNews() async throws -> NewsListResponse {
        let response: APIResponse<NewsListResponse> =
            try await APIClient.shared.request(
                endpoint: "/api/v1/news/recommendations"
            )

        return response.data
    }
}

