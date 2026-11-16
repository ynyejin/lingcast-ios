import SwiftUI

struct ProfileView: View {

    @Environment(AuthSession.self) private var auth

    @State private var selectedLevel = EnglishLevel.intermediate
    @State private var showingLogoutAlert = false

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

                ProfileLevelSelector(
                    selectedLevel: $selectedLevel
                )

                ProfileInterestsSection(
                    interests: ProfileMockData.interests
                )

                ProfileLearningStatsCard(
                    stats: ProfileMockData.learningStats
                )

                // 로그아웃 버튼
                Button {
                    showingLogoutAlert = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")

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
        .alert("로그아웃", isPresented: $showingLogoutAlert) {
            Button("취소", role: .cancel) {}

            Button("로그아웃", role: .destructive) {
                auth.logOut()
            }
        } message: {
            Text("정말 로그아웃하시겠습니까?")
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthSession())
}
