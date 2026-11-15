
import SwiftUI

struct TodayNewsFeedView: View {
    @State private var selectedCategory: String

    @State private var newsStories: [HomeStory] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    init(initialCategory: String) {
        _selectedCategory = State(
            initialValue: Self.displayCategory(for: initialCategory)
        )
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

    private static func displayCategory(for category: String) -> String {
        switch category.uppercased() {
        case "IT", "TECH", "TECHNOLOGY":
            return "Tech"
        case "경제", "BUSINESS":
            return "Business"
        case "과학", "SCIENCE":
            return "Science"
        case "HEALTH":
            return "Health"
        case "DESIGN":
            return "Design"
        case "MARKETING":
            return "Marketing"
        case "EDUCATION":
            return "Education"
        case "LAW":
            return "Law"
        case "ENVIRONMENT":
            return "Environment"
        default:
            return "All"
        }
    }

    private func apiCategory(for category: String) -> String? {
        if category == "All" || category == "전체" {
            return nil
        }

        return category.uppercased()
    }

    @MainActor
    private func loadNews(category: String) async {
        isLoading = true
        errorMessage = nil
        newsStories = []

        defer {
            isLoading = false
        }

        do {
            let response = try await NewsService.shared.getNews(
                category: apiCategory(for: category) ?? ""
            )

            guard !Task.isCancelled else { return }

            newsStories = response.content.map {
                HomeStory(news: $0)
            }

            print(
                "전체 보기 뉴스 로딩 성공:",
                category,
                newsStories.count
            )

        } catch {
            guard !Task.isCancelled else { return }

            errorMessage = "뉴스를 불러오지 못했습니다."
            print("전체 보기 뉴스 로딩 실패:", error)
        }
    }
}

#Preview {
    NavigationStack {
        TodayNewsFeedView(initialCategory: "All")
    }
}

