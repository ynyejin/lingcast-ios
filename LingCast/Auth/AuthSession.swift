
import Foundation
import Observation

@MainActor
@Observable
final class AuthSession {

    enum PreferenceStatus {
        case checking
        case needsSetup
        case completed
        case failed
    }

    var isLoggedIn = false
    var isLoading = false
    var errorMessage: String?
    var preferenceStatus: PreferenceStatus = .checking

    // 현재 로그인한 사용자의 닉네임
    var nickname: String?

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

            nickname = response.user.nickname
            preferenceStatus = .checking
            isLoggedIn = true

        } catch {
            errorMessage = "이메일 또는 비밀번호를 확인해주세요."
            isLoggedIn = false
            print("로그인 실패:", error)
        }

        isLoading = false
    }

    // 앱 재실행 시 사용자 정보 복원
    func loadMyInfo() async {
        do {
            let user = try await AuthService.shared.getMyInfo()

            guard !Task.isCancelled, isLoggedIn else { return }

            nickname = user.nickname
            print("사용자 정보 조회 성공:", user.nickname)

        } catch {
            print("사용자 정보 조회 실패:", error)
        }
    }

    func checkPreferences() async {
        preferenceStatus = .checking

        do {
            let preferences =
                try await PreferenceService.shared.getPreferences()

            guard !Task.isCancelled, isLoggedIn else { return }

            if preferences.englishLevel == nil ||
                preferences.categories.isEmpty {
                preferenceStatus = .needsSetup
            } else {
                preferenceStatus = .completed
            }

        } catch {
            guard !Task.isCancelled, isLoggedIn else { return }

            preferenceStatus = .failed
            print("사용자 설정 조회 실패:", error)
        }
    }

    func completeOnboarding() {
        preferenceStatus = .completed
    }

    func logOut() {
        clearSession()
    }

    func handleAuthenticationExpired() {
        clearSession()
        errorMessage = "로그인 세션이 만료되었습니다. 다시 로그인해주세요."
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")

        nickname = nil
        errorMessage = nil
        preferenceStatus = .checking
        isLoggedIn = false
    }
}

