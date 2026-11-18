
import SwiftUI
import SafariServices

struct NewsDetailView: View {
    let newsId: Int64

    @State private var news: NewsDetailResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var safariURL: URL?

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Group {
                    if isLoading {
                        ProgressView("뉴스를 불러오는 중...")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)

                    } else if let errorMessage {
                        ContentUnavailableView(
                            errorMessage,
                            systemImage: "wifi.exclamationmark"
                        )

                    } else if let news {
                        newsContent(news)
                            .frame(
                                width: geometry.size.width,
                                alignment: .leading
                            )

                    } else {
                        ContentUnavailableView(
                            "뉴스를 찾을 수 없습니다",
                            systemImage: "newspaper"
                        )
                    }
                }
            }
            .background(LingcastColor.background.ignoresSafeArea())
            .navigationTitle("뉴스 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .sheet(
                isPresented: Binding(
                    get: { safariURL != nil },
                    set: { if !$0 { safariURL = nil } }
                )
            ) {
                if let safariURL {
                    SafariView(url: safariURL)
                        .ignoresSafeArea()
                }
            }
            .task(id: newsId) {
                await loadNewsDetail()
            }
        }
    }

    private func newsContent(_ news: NewsDetailResponse) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            // 기사 이미지
            if let imageUrl = news.imageUrl,
               let url = URL(string: imageUrl),
               ["http", "https"].contains(url.scheme?.lowercased() ?? "") {

                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(LingcastColor.secondaryText.opacity(0.1))
                        .overlay {
                            ProgressView()
                        }
                }
                .frame(maxWidth: .infinity)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
            }

            // 카테고리
            Text(news.category)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(LingcastColor.secondaryText)

            // 기사 제목
            Text(news.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(LingcastColor.primaryText)

            // 언론사 및 발행일
            HStack(spacing: 8) {
                Text(news.source)

                if let publishedAt = news.publishedAt {
                    Text("·")
                    Text(String(publishedAt.prefix(10)))
                }
            }
            .font(.caption)
            .foregroundStyle(LingcastColor.secondaryText)

            Divider()

            // 기사 요약
            VStack(alignment: .leading, spacing: 12) {
                Text("Article Summary")
                    .font(.headline)
                    .foregroundStyle(LingcastColor.primaryText)

                if let summary = news.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.body)
                        .foregroundStyle(LingcastColor.primaryText)
                        .lineSpacing(6)
                } else {
                    Text("제공된 기사 요약이 없습니다.")
                        .font(.subheadline)
                        .foregroundStyle(LingcastColor.secondaryText)
                }
            }

            // 원문 보기
            Button {
                guard let url = URL(string: news.originalUrl),
                      ["http", "https"].contains(url.scheme?.lowercased() ?? ""),
                      url.host != nil else {
                    return
                }
                safariURL = url
            } label: {
                HStack {
                    Text("원문 기사 보기")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(18)
                .background(
                    LingcastColor.darkSurface,
                    in: RoundedRectangle(cornerRadius: 14)
                )
            }
        }
        .padding(.horizontal, HomeLayout.horizontalPadding)
        .padding(.vertical, 20)
    }

    @MainActor
    private func loadNewsDetail() async {
        isLoading = true
        errorMessage = nil
        news = nil

        defer { isLoading = false }

        do {
            let response = try await NewsService.shared.getNewsDetail(
                newsId: newsId
            )

            guard !Task.isCancelled else { return }
            news = response

        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = "뉴스 상세 정보를 불러오지 못했습니다."
            print("뉴스 상세 조회 실패:", error)
        }
    }
}

// 앱 내부 Safari
private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}
}

