import SwiftUI

struct HomeView: View {
    @State private var selectedCategory = HomeMockData.categories[0]
    @State private var featuredStoryID: String?

    @State private var isShowingAllNews = false
    @State private var isShowingRecommended = false

    // 서버에서 받아온 실제 뉴스
    @State private var newsStories: [HomeStory] = []

    // 뉴스 로딩 및 오류 상태
    @State private var isLoadingNews = false
    @State private var newsErrorMessage: String?

    // 서버에서 받아온 추천 뉴스
    @State private var recommendedStories: [HomeStory] = []

    // 추천 뉴스 로딩 및 오류 상태
    @State private var isLoadingRecommended = false
    @State private var recommendedErrorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: HomeLayout.sectionSpacing
                ) {
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

            // 오늘의 주요 뉴스 전체 보기
            .navigationDestination(isPresented: $isShowingAllNews) {
                TodayNewsFeedView(initialCategory: selectedCategory)
            }

            // 추천 콘텐츠 전체 보기
            .navigationDestination(isPresented: $isShowingRecommended) {
                EditorialNewsFeedView(
                    title: "추천 콘텐츠",
                    subtitle: "관심 분야를 바탕으로 추천했어요",
                    stories: recommendedStories,
                    isLoading: isLoadingRecommended,
                    errorMessage: recommendedErrorMessage
                )
            }

            // 선택한 카테고리의 뉴스 조회
            .task(id: selectedCategory) {
                await loadNews(category: selectedCategory)
            }

            // 추천 뉴스 조회
            .task {
                await loadRecommendedNews()
            }
        }
    }

    // MARK: - 오늘의 주요 뉴스

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

            if isLoadingNews {
                ProgressView("뉴스를 불러오는 중...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

            } else if let newsErrorMessage {
                Text(newsErrorMessage)
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

            } else if newsStories.isEmpty {
                Text("표시할 뉴스가 없습니다.")
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

            } else {
                FeaturedNewsCarousel(
                    stories: newsStories,
                    currentStoryID: $featuredStoryID
                )
                .id(selectedCategory)
            }
        }
    }

    // MARK: - 추천 콘텐츠

    private var recommendedSection: some View {
        VStack(
            alignment: .leading,
            spacing: HomeLayout.itemSpacing
        ) {
            HomeSectionHeader(
                title: "추천 콘텐츠",
                actionTitle: "전체 보기",
                action: { isShowingRecommended = true }
            )
            .padding(.horizontal, HomeLayout.horizontalPadding)

            if isLoadingRecommended {
                ProgressView("추천 뉴스를 불러오는 중...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

            } else if let recommendedErrorMessage {
                Text(recommendedErrorMessage)
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

            } else if recommendedStories.isEmpty {
                Text("추천 콘텐츠가 없습니다.")
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

            } else {
                GeometryReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(recommendedStories) { story in
                                RecommendedStoryCard(story: story)
                                    .frame(
                                        width: proxy.size.width * 0.72
                                    )
                            }
                        }
                        .padding(
                            .horizontal,
                            HomeLayout.horizontalPadding
                        )
                    }
                }
                .frame(height: 250)
            }
        }
    }

    // MARK: - 계속 학습하기

    private var continueLearningSection: some View {
        VStack(
            alignment: .leading,
            spacing: HomeLayout.itemSpacing
        ) {
            HomeSectionHeader(title: "계속 학습하기")
            ContinueLearningCard()
        }
        .padding(.horizontal, HomeLayout.horizontalPadding)
    }

    // MARK: - 주제 탐색

    private var exploreSection: some View {
        VStack(
            alignment: .leading,
            spacing: HomeLayout.itemSpacing
        ) {
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

    // MARK: - 실제 뉴스 API

    @MainActor
    private func loadNews(category: String) async {
        isLoadingNews = true
        newsErrorMessage = nil
        newsStories = []
        featuredStoryID = nil

        do {
            let response = try await NewsService.shared.getNews(
                category: category
            )

            // 이전 요청이 취소되었다면 결과 반영하지 않음
            guard !Task.isCancelled else { return }

            newsStories = response.content.map {
                HomeStory(news: $0)
            }

            print("뉴스 로딩 성공 - 카테고리:", category)
            print("뉴스 개수:", newsStories.count)

        } catch {
            guard !Task.isCancelled else { return }

            newsErrorMessage = "뉴스를 불러오지 못했습니다."
            print("뉴스 로딩 실패:", error)
        }

        isLoadingNews = false
    }

    // MARK: - 추천 뉴스 API

    @MainActor
    private func loadRecommendedNews() async {
        isLoadingRecommended = true
        recommendedErrorMessage = nil

        do {
            let response = try await NewsService.shared.getRecommendedNews()

            guard !Task.isCancelled else { return }

            recommendedStories = response.content.map {
                HomeStory(news: $0)
            }

            print("추천 뉴스 로딩 성공:", recommendedStories.count)

        } catch {
            guard !Task.isCancelled else { return }

            recommendedErrorMessage = "추천 뉴스를 불러오지 못했습니다."
            print("추천 뉴스 로딩 실패:", error)
        }

        isLoadingRecommended = false
    }
}

#Preview {
    HomeView()
}
