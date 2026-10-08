//
//  NewsModels.swift
//  LingCast
//
//  Created by 윤예진 on 10/8/26.
//

import Foundation

// 뉴스 목록의 개별 기사 정보
struct NewsListItem: Decodable {
    let newsId: Int64
    let title: String
    let source: String
    let category: String
    let publishedAt: String?
    let summary: String?
    let imageUrl: String?
}

// 뉴스 목록 API 응답
struct NewsListResponse: Decodable {
    let content: [NewsListItem]
    let page: Int
    let size: Int
    let totalElements: Int64
    let totalPages: Int
}
