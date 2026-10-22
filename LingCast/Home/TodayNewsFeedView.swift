//
//  TodayNewsFeedView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct TodayNewsFeedView: View {
    @State private var selectedCategory: String

    // 실제 뉴스 데이터
    @State private var newsStories: [HomeStory] = []

    // 로딩 및 오류 상태
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(initialCategory: String) {
        _selectedCategory = State(initialValue: initialCategory)
    }

    var body: some View {
        EditorialNewsFeedView(
            title: "오늘의 주요 뉴스",
            stories: newsStories,
            selectedCategory: $selectedCategory,
            isLoading: isLoading,
            errorMessage: errorMessage
        )
        .task(id: selectedCategory) {
            await loadNews(category: selectedCategory)
        }
    }

    // 선택한 카테고리의 실제 뉴스 조회
    @MainActor
    private func loadNews(category: String) async {
        isLoading = true
        errorMessage = nil
        newsStories = []

        do {
            let response = try await NewsService.shared.getNews(
                category: category
            )

            // 이전 요청 결과가 뒤늦게 도착한 경우 무시
            guard !Task.isCancelled else { return }

            newsStories = response.content.map {
                HomeStory(news: $0)
            }

            print("전체 보기 뉴스 로딩 성공:", category, newsStories.count)

        } catch {
            guard !Task.isCancelled else { return }

            errorMessage = "뉴스를 불러오지 못했습니다."
            print("전체 보기 뉴스 로딩 실패:", error)
        }

        isLoading = false
    }
}

#Preview {
    NavigationStack {
        TodayNewsFeedView(initialCategory: "IT")
    }
}
