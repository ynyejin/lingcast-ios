
import SwiftUI

struct LearnView: View {
    @State private var isShowingLearningHistory = false

    // 서버에서 가져온 최근 학습 기록
    @State private var recentItems: [RecentLearningItem] = []
    @State private var isLoading = false
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HomeLayout.sectionSpacing) {
                    LearnHeaderView()

                    // 주간 학습 요약은 아직 Mock 데이터 유지
                    WeeklyLearningCard(summary: LearnMockData.weekly)

                    recentSection
                    reviewSection
                }
                .padding(.horizontal, HomeLayout.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
            .background(LingcastColor.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $isShowingLearningHistory) {
                RecentLearningView()
            }
            .task {
                await loadRecentLearning()
            }
            .refreshable {
                await loadRecentLearning()
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            HomeSectionHeader(
                title: "최근 학습한 콘텐츠",
                actionTitle: "전체 보기",
                action: { isShowingLearningHistory = true }
            )

            if isLoading && recentItems.isEmpty {
                ProgressView("학습 기록을 불러오는 중...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)

            } else if let loadError, recentItems.isEmpty {
                VStack(spacing: 10) {
                    Text("학습 기록을 불러오지 못했어요.")
                        .font(.subheadline)
                        .foregroundStyle(LingcastColor.secondaryText)

                    Button("다시 시도") {
                        Task {
                            await loadRecentLearning()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                #if DEBUG
                Text(loadError)
                    .font(.caption2)
                    .foregroundStyle(LingcastColor.secondaryText)
                #endif

            } else if recentItems.isEmpty {
                Text("아직 학습한 콘텐츠가 없어요.")
                    .font(.subheadline)
                    .foregroundStyle(LingcastColor.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)

            } else {
                ForEach(recentItems) { item in
                    RecentLearningRow(item: item)
                }
            }
        }
    }

    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: HomeLayout.itemSpacing) {
            HomeSectionHeader(title: "복습이 필요해요")

            HStack(alignment: .top, spacing: 12) {
                ForEach(LearnMockData.reviewPrompts) { prompt in
                    ReviewNeedCard(prompt: prompt)
                }
            }
        }
    }

    @MainActor
    private func loadRecentLearning() async {
        guard !isLoading else { return }

        isLoading = true
        loadError = nil
        defer { isLoading = false }

        do {
            let page = try await PodcastService.shared.getPodcastHistories(
                page: 0,
                size: 2
            )

            recentItems = page.content.map {
                RecentLearningItem(history: $0)
            }

        } catch {
            loadError = error.localizedDescription
            print("최근 학습 기록 조회 실패: \(error)")
        }
    }
}

#Preview {
    LearnView()
}

