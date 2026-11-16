
import SwiftUI

struct ContentView: View {

    @State private var auth = AuthSession()

    var body: some View {
        Group {
            if auth.isLoggedIn {
                authenticatedContent
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .environment(auth)
        .task(id: auth.isLoggedIn) {
            guard auth.isLoggedIn else { return }

            // 사용자 정보와 설정을 각각 조회
            async let myInfo: Void = auth.loadMyInfo()
            async let preferences: Void = auth.checkPreferences()

            _ = await (myInfo, preferences)
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: APIClient.authenticationExpired
            )
        ) { _ in
            auth.handleAuthenticationExpired()
        }
    }

    @ViewBuilder
    private var authenticatedContent: some View {
        switch auth.preferenceStatus {

        case .checking:
            ProgressView("사용자 설정을 확인하는 중...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .needsSetup:
            OnboardingPreferencesView()

        case .completed:
            MainTabView()

        case .failed:
            VStack(spacing: 16) {
                Text("사용자 설정을 불러오지 못했습니다.")
                    .font(.headline)

                Button("다시 시도") {
                    Task {
                        await auth.checkPreferences()
                    }
                }

                Button("로그아웃") {
                    auth.logOut()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}

