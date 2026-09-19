//
//  TodayNewsFeedView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct TodayNewsFeedView: View {
    @State private var selectedCategory: String

    init(initialCategory: String) {
        _selectedCategory = State(initialValue: initialCategory)
    }

    var body: some View {
        EditorialNewsFeedView(
            title: "오늘의 주요 뉴스",
            stories: HomeMockData.feedStories(for: selectedCategory),
            selectedCategory: $selectedCategory
        )
    }
}

#Preview {
    NavigationStack {
        TodayNewsFeedView(initialCategory: "IT")
    }
}
