import SwiftUI

struct FeaturedNewsCarousel: View {

    let stories: [HomeStory]
    @Binding var currentStoryID: String?

    private let cardHeight: CGFloat = 360
    private let cardWidthRatio: CGFloat = 0.78
    private let cardSpacing: CGFloat = 14

    // 실제 스크롤 위치를 추적하기 위한 내부 ID
    @State private var scrollID: String?

    var body: some View {
        VStack(spacing: 14) {

            GeometryReader { proxy in

                let cardWidth = proxy.size.width * cardWidthRatio
                let sideInset = (proxy.size.width - cardWidth) / 2

                ScrollView(.horizontal, showsIndicators: false) {

                    LazyHStack(spacing: cardSpacing) {

                        ForEach(loopStories) { item in

                            FeaturedStoryCard(story: item.story)
                                .frame(
                                    width: cardWidth,
                                    height: cardHeight
                                )
                                .scrollTransition(
                                    .interactive,
                                    axis: .horizontal
                                ) { content, phase in

                                    content
                                        .scaleEffect(
                                            phase.isIdentity ? 1.0 : 0.94
                                        )
                                        .opacity(
                                            phase.isIdentity ? 1.0 : 0.82
                                        )
                                }
                                .id(item.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(
                    .horizontal,
                    sideInset,
                    for: .scrollContent
                )
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollID)
                .scrollClipDisabled()
            }
            .frame(height: cardHeight)

            pageIndicator
        }
        .onAppear {
            guard !stories.isEmpty else { return }

            let firstID = realID(for: stories[0])

            scrollID = firstID
            currentStoryID = stories[0].id
        }
        .onChange(of: scrollID) { _, newID in
            handleScrollPosition(newID)
        }
        .onChange(of: stories.map(\.id)) { _, _ in
            guard !stories.isEmpty else {
                scrollID = nil
                currentStoryID = nil
                return
            }

            let firstID = realID(for: stories[0])

            scrollID = firstID
            currentStoryID = stories[0].id
        }
    }

    // MARK: - Infinite Loop Data

    private var loopStories: [LoopStory] {

        guard stories.count > 1 else {
            return stories.map {
                LoopStory(
                    id: realID(for: $0),
                    story: $0,
                    type: .real
                )
            }
        }

        var result: [LoopStory] = []

        // 맨 앞에 마지막 카드 복제
        if let last = stories.last {
            result.append(
                LoopStory(
                    id: "clone-leading-\(last.id)",
                    story: last,
                    type: .leadingClone
                )
            )
        }

        // 실제 카드들
        for story in stories {
            result.append(
                LoopStory(
                    id: realID(for: story),
                    story: story,
                    type: .real
                )
            )
        }

        // 맨 뒤에 첫 카드 복제
        if let first = stories.first {
            result.append(
                LoopStory(
                    id: "clone-trailing-\(first.id)",
                    story: first,
                    type: .trailingClone
                )
            )
        }

        return result
    }

    // MARK: - Loop Handling

    private func handleScrollPosition(_ id: String?) {

        guard
            let id,
            stories.count > 1,
            let first = stories.first,
            let last = stories.last
        else {
            return
        }

        // 맨 앞 복제 ⑤에 도착
        if id == "clone-leading-\(last.id)" {

            currentStoryID = last.id

            DispatchQueue.main.async {
                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    scrollID = realID(for: last)
                }
            }

            return
        }

        // 맨 뒤 복제 ①에 도착
        if id == "clone-trailing-\(first.id)" {

            currentStoryID = first.id

            DispatchQueue.main.async {
                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    scrollID = realID(for: first)
                }
            }

            return
        }

        // 일반 카드
        if id.hasPrefix("real-") {

            let storyID = String(
                id.dropFirst("real-".count)
            )

            currentStoryID = storyID
        }
    }

    private func realID(for story: HomeStory) -> String {
        "real-\(story.id)"
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {

        HStack(spacing: 6) {

            ForEach(stories) { story in

                Circle()
                    .fill(
                        story.id == currentStoryID
                            ? LingcastColor.primaryText
                            : LingcastColor.secondaryText.opacity(0.28)
                    )
                    .frame(width: 6, height: 6)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "주요 뉴스 \(currentIndex + 1) / \(stories.count)"
        )
    }

    private var currentIndex: Int {
        max(
            stories.firstIndex {
                $0.id == currentStoryID
            } ?? 0,
            0
        )
    }
}

// MARK: - Loop Model

private struct LoopStory: Identifiable {

    let id: String
    let story: HomeStory
    let type: LoopStoryType
}

private enum LoopStoryType {
    case leadingClone
    case real
    case trailingClone
}

#Preview {
    FeaturedNewsCarousel(
        stories: HomeMockData.featuredStories(for: "전체"),
        currentStoryID: .constant(nil)
    )
    .background(LingcastColor.background)
}
