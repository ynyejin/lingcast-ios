//
//  AuthService.swift
//  LingCast
//
//  Created by 윤예진 on 10/7/26.
//

import Foundation

final class AuthService {

    static let shared = AuthService()

    private init() {}

    func login(
        email: String,
        password: String
    ) async throws -> LoginResponse {

        let loginRequest = LoginRequest(
            email: email,
            password: password
        )

        let body = try JSONEncoder().encode(loginRequest)

        let response: APIResponse<LoginResponse> =
            try await APIClient.shared.request(
                endpoint: "/api/v1/auth/login",
                method: "POST",
                body: body
            )

        return response.data
    }
    
    func signup(
        email: String,
        password: String,
        nickname: String
    ) async throws -> SignupResponse {

        let signupRequest = SignupRequest(
            email: email,
            password: password,
            nickname: nickname
        )

        let body = try JSONEncoder().encode(signupRequest)

        let response: APIResponse<SignupResponse> =
            try await APIClient.shared.request(
                endpoint: "/api/v1/users/signup",
                method: "POST",
                body: body
            )

        return response.data
    }
}
