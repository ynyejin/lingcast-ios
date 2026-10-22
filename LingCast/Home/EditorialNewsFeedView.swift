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

    // 뉴스 조회 상태
    var isLoading: Bool = false
    var errorMessage: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // 카테고리 선택
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

                // 뉴스 목록 상태에 따라 화면 표시
                if isLoading {
                    ProgressView("뉴스를 불러오는 중...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)

                } else if let errorMessage {
                    ContentUnavailableView(
                        errorMessage,
                        systemImage: "wifi.exclamationmark"
                    )

                } else if stories.isEmpty {
                    ContentUnavailableView(
                        "뉴스가 없습니다",
                        systemImage: "newspaper",
                        description: Text("해당 카테고리의 뉴스가 아직 없습니다.")
                    )

                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(stories) { story in
                            NewsFeedStoryCard(story: story)
                        }
                    }
                    .padding(.horizontal, HomeLayout.horizontalPadding)
                }
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
