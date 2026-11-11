import Foundation
import Observation

@MainActor
@Observable
final class AuthSession {

    var isLoggedIn = false
    var isLoading = false
    var errorMessage: String?

    init() {
        if let accessToken = UserDefaults.standard.string(
            forKey: "accessToken"
        ), !accessToken.isEmpty {
            isLoggedIn = true
        }
    }

    func logIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await AuthService.shared.login(
                email: email,
                password: password
            )

            UserDefaults.standard.set(
                response.accessToken,
                forKey: "accessToken"
            )

            UserDefaults.standard.set(
                response.refreshToken,
                forKey: "refreshToken"
            )

            isLoggedIn = true

        } catch {
            errorMessage = "이메일 또는 비밀번호를 확인해주세요."
            isLoggedIn = false

            print("로그인 실패:", error)
        }

        isLoading = false
    }

    // 사용자가 직접 로그아웃
    func logOut() {
        clearSession()
    }

    // Refresh Token 만료 등으로 인증이 종료된 경우
    func handleAuthenticationExpired() {
        clearSession()
        errorMessage = "로그인 세션이 만료되었습니다. 다시 로그인해주세요."
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(
            forKey: "accessToken"
        )

        UserDefaults.standard.removeObject(
            forKey: "refreshToken"
        )

        errorMessage = nil
        isLoggedIn = false
    }
}
