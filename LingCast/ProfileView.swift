
import SwiftUI

struct ProfileView: View {

    @Environment(AuthSession.self) private var auth

    @State private var selectedLevel = EnglishLevel.intermediate
    @State private var selectedCategories: [String] = []

    @State private var isLoadingPreferences = true
    @State private var isSavingLevel = false
    @State private var preferenceErrorMessage: String?

    @State private var showingInterestsEditor = false
    @State private var showingLogoutAlert = false

    // 영어 수준 변경 실패 시 복원할 값
    @State private var savedLevel = EnglishLevel.intermediate

    private let categoryNames: [String: String] = [
        "TECH": "Tech",
        "BUSINESS": "Business",
        "HEALTH": "Health",
        "SCIENCE": "Science",
        "DESIGN": "Design",
        "MARKETING": "Marketing",
        "EDUCATION": "Education",
        "LAW": "Law",
        "ENVIRONMENT": "Environment"
    ]

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: HomeLayout.sectionSpacing
            ) {
                ProfileHeaderView()

                ProfileUserCard(
                    user: ProfileUser(
                        name: auth.nickname ?? "회원",
                        subtitle: "개인 맞춤 뉴스 팟캐스트",
                        initial: String((auth.nickname ?? "회").prefix(1))
                    )
                )

                if isLoadingPreferences {
                    ProgressView("설정을 불러오는 중...")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                } else {
                    VStack(
                        alignment: .leading,
                        spacing: HomeLayout.sectionSpacing
                    ) {
                        ProfileLevelSelector(
                            selectedLevel: $selectedLevel
                        )
                        .disabled(isSavingLevel)
                        .onChange(of: selectedLevel) { _, newValue in
                            guard newValue != savedLevel else { return }

                            Task {
                                await updateEnglishLevel(newValue)
                            }
                        }

                        ProfileInterestsSection(
                            interests: selectedCategories.map {
                                categoryNames[$0] ?? $0
                            },
                            onEdit: {
                                showingInterestsEditor = true
                            }
                        )
                    }
                }

                if let preferenceErrorMessage {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(preferenceErrorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)

                        Button("다시 불러오기") {
                            Task {
                                await loadPreferences()
                            }
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                }

                ProfileLearningStatsCard(
                    stats: ProfileMockData.learningStats
                )

                Button {
                    showingLogoutAlert = true
                } label: {
                    HStack(spacing: 10) {
                        Image(
                            systemName: "rectangle.portrait.and.arrow.right"
                        )

                        Text("로그아웃")
                            .font(.subheadline.weight(.medium))

                        Spacer()
                    }
                    .foregroundStyle(.red.opacity(0.85))
                    .padding(18)
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.white.opacity(0.05),
                        in: RoundedRectangle(
                            cornerRadius: 16,
                            style: .continuous
                        )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HomeLayout.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .scrollIndicators(.hidden)
        .background(LingcastColor.background.ignoresSafeArea())
        .task {
            await loadPreferences()
        }
        .sheet(isPresented: $showingInterestsEditor) {
            ProfileInterestsEditView(
                selectedCategories: selectedCategories,
                englishLevel: selectedLevel.rawValue.uppercased()
            ) { updatedCategories in
                selectedCategories = updatedCategories
            }
        }
        .alert("로그아웃", isPresented: $showingLogoutAlert) {
            Button("취소", role: .cancel) {}

            Button("로그아웃", role: .destructive) {
                auth.logOut()
            }
        } message: {
            Text("정말 로그아웃하시겠습니까?")
        }
    }

    // MARK: - 설정 조회

    @MainActor
    private func loadPreferences() async {
        isLoadingPreferences = true
        preferenceErrorMessage = nil

        defer {
            isLoadingPreferences = false
        }

        do {
            let preferences =
                try await PreferenceService.shared.getPreferences()

            guard !Task.isCancelled else { return }

            if let level = preferences.englishLevel,
               let parsedLevel = EnglishLevel.allCases.first(
                where: { $0.rawValue.uppercased() == level.uppercased() }
               ) {
                selectedLevel = parsedLevel
                savedLevel = parsedLevel
            }

            selectedCategories = preferences.categories

        } catch {
            guard !Task.isCancelled else { return }

            preferenceErrorMessage = "설정을 불러오지 못했습니다."
            print("프로필 설정 조회 실패:", error)
        }
    }

    // MARK: - 영어 수준 변경

    @MainActor
    private func updateEnglishLevel(_ newLevel: EnglishLevel) async {
        guard !isSavingLevel else { return }

        isSavingLevel = true
        preferenceErrorMessage = nil

        do {
            try await PreferenceService.shared.updatePreferences(
                englishLevel: newLevel.rawValue.uppercased(),
                categories: selectedCategories
            )

            savedLevel = newLevel

        } catch {
            selectedLevel = savedLevel
            preferenceErrorMessage = "영어 수준 변경에 실패했습니다."
            print("영어 수준 변경 실패:", error)
        }

        isSavingLevel = false
    }
}

#Preview {
    ProfileView()
        .environment(AuthSession())
}

