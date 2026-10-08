//
//  NewsService.swift
//  LingCast
//
//  Created by 윤예진 on 10/8/26.
//

import Foundation

final class NewsService {

    static let shared = NewsService()

    private init() {}

    // 카테고리별 뉴스 목록 조회
    func getNews(category: String = "전체") async throws -> NewsListResponse {

        var endpoint = "/api/v1/news"

        // 전체가 아닌 경우 카테고리 쿼리 파라미터 추가
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
}
