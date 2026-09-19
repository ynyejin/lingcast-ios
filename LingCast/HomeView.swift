//
//  HomeView.swift
//  LingCast
//
//  Created by 윤예진 on 9/11/26.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedCategory = HomeMockData.categories[0]
    @State private var featuredStoryID: String?

    @State private var isShowingAllNews = false
    @State private var isShowingRecommended = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
                    HomeHeaderView()
                        .padding(.horizontal, HomeLayout.horizontalPadding)

                    featuredNewsSection
                    recommendedSection
                    continueLearningSection
                    exploreSection
                }
                .padding(.top, 8)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
            .background(LingcastColor.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $isShowingAllNews) {
                TodayNewsFeedView(initialCategory: selectedCategory)
            }
            .navigationDestination(isPresented: $isShowingRecommended) {
                EditorialNewsFeedView(
                    title: "추천 콘텐츠",
                    subtitle: "관심 분야를 바탕으로 추천했어요",
                    stories: HomeMockData.recommended
                )
            }
        }
    }

    private var featuredNewsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(
                title: "오늘의 주요 뉴스",
                actionTitle: "전체 보기",
                showsChevron: true,
                action: { isShowingAllNews = true }
            )
            .padding(.horizontal, HomeLayout.horizontalPadding)

            CategoryFilterView(selectedCategory: $selectedCategory)
                .padding(.horizontal, HomeLayout.horizontalPadding)

            FeaturedNewsCarousel(
                stories: HomeMockData.featuredStories(for: selectedCategory),
                currentStoryID: $featuredStoryID
            )
            .id(selectedCategory)
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            HomeSectionHeader(
                title: "추천 콘텐츠",
                actionTitle: "전체 보기",
                action: { isShowingRecommended = true }
            )
                .padding(.horizontal, HomeLayout.horizontalPadding)

            GeometryReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(HomeMockData.recommended) { story in
                            RecommendedStoryCard(story: story)
                                .frame(width: proxy.size.width * 0.72)
                        }
                    }
                    .padding(.horizontal, HomeLayout.horizontalPadding)
                }
            }
            .frame(height: 250)
        }
    }

    private var continueLearningSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            HomeSectionHeader(title: "계속 학습하기")
            ContinueLearningCard()
        }
        .padding(.horizontal, HomeLayout.horizontalPadding)
    }

    private var exploreSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            HomeSectionHeader(title: "주제 탐색")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(HomeMockData.topics) { topic in
                    ExploreTopicCard(topic: topic)
                }
            }
        }
        .padding(.horizontal, HomeLayout.horizontalPadding)
    }
}

#Preview {
    HomeView()
}
