
import SwiftUI

struct RecentLearningView: View {
    @State private var learningHistory: [RecentLearningItem] = []
    @State private var currentPage = 0
    @State private var hasMorePages = true
    @State private var isLoading = false
    @State private var loadError: String?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {

                if learningHistory.isEmpty {
                    if isLoading {
                        ProgressView("학습 기록을 불러오는 중...")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)

                    } else if loadError != nil {
                        VStack(spacing: 12) {
                            Text("학습 기록을 불러오지 못했어요.")
                                .foregroundStyle(LingcastColor.secondaryText)

                            Button("다시 시도") {
                                Task {
                                    await loadHistory(reset: true)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)

                    } else {
                        Text("아직 학습한 콘텐츠가 없어요.")
                            .font(.subheadline)
                            .foregroundStyle(LingcastColor.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                    }

                } else {
                    ForEach(learningHistory) { item in
                        RecentLearningHistoryRow(item: item)
                    }

                    if hasMorePages {
                        if isLoading {
                            ProgressView()
                                .padding(.vertical, 16)
                        } else {
                            Button("더 보기") {
                                Task {
                                    await loadHistory()
                                }
                            }
                            .padding(.vertical, 16)
                        }
                    }

                    if loadError != nil {
                        Button("불러오기 실패 · 다시 시도") {
                            Task {
                                await loadHistory()
                            }
                        }
                        .font(.subheadline)
                        .padding(.vertical, 12)
                    }
                }
            }
            .padding(.horizontal, HomeLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .background(LingcastColor.background.ignoresSafeArea())
        .navigationTitle("최근 학습한 콘텐츠")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(LingcastColor.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            if learningHistory.isEmpty {
                await loadHistory(reset: true)
            }
        }
        .refreshable {
            await loadHistory(reset: true)
        }
    }

    @MainActor
    private func loadHistory(reset: Bool = false) async {
        guard !isLoading else { return }
        guard reset || hasMorePages else { return }

        isLoading = true
        loadError = nil
        defer { isLoading = false }

        let pageToLoad = reset ? 0 : currentPage

        do {
            let response = try await PodcastService.shared.getPodcastHistories(
                page: pageToLoad,
                size: 20
            )

            let newItems = response.content.map {
                RecentLearningItem(history: $0)
            }

            if reset {
                learningHistory = newItems
            } else {
                learningHistory.append(contentsOf: newItems)
            }

            currentPage = pageToLoad + 1
            hasMorePages = !response.last

        } catch {
            loadError = error.localizedDescription
            print("전체 학습 기록 조회 실패: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        RecentLearningView()
    }
}

