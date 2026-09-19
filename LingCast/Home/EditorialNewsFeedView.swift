//
//  EditorialNewsFeedView.swift
//  LingCast
//
//  Created by 윤예진 on 9/19/26.
//

import SwiftUI

struct EditorialNewsFeedView: View {
    let title: String
    var subtitle: String? = nil
    var stories: [HomeStory]
    var selectedCategory: Binding<String>? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let selectedCategory {
                    CategoryFilterView(selectedCategory: selectedCategory)
                        .padding(.horizontal, HomeLayout.horizontalPadding)
                }

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(LingcastColor.secondaryText)
                        .padding(.horizontal, HomeLayout.horizontalPadding)
                }

                LazyVStack(spacing: 16) {
                    ForEach(stories) { story in
                        NewsFeedStoryCard(story: story)
                    }
                }
                .padding(.horizontal, HomeLayout.horizontalPadding)
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .background(LingcastColor.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(LingcastColor.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        EditorialNewsFeedView(
            title: "추천 콘텐츠",
            subtitle: "관심 분야를 바탕으로 추천했어요",
            stories: HomeMockData.recommended
        )
    }
}
