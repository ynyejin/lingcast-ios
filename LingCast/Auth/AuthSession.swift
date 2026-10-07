//
//  AuthSession.swift
//  LingCast
//
//  Created by 윤예진 on 10/7/26.
//

import Foundation
import Observation

@Observable
final class AuthSession {

    var isLoggedIn = false
    var isLoading = false
    var errorMessage: String?

    func logIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // 백엔드 로그인 API 호출
            let response = try await AuthService.shared.login(
                email: email,
                password: password
            )

            // 로그인 성공 시 토큰 저장
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
            // 로그인 실패
            errorMessage = "이메일 또는 비밀번호를 확인해주세요."
            isLoggedIn = false
            print("로그인 실패:", error)
        }

        isLoading = false
    }
}
