import Foundation

final class APIClient {

    static let shared = APIClient()

    private init() {}

    // Spring Boot 서버 주소
    private let baseURL = "http://localhost:8080"

    // 인증 만료 알림
    static let authenticationExpired =
        Notification.Name("authenticationExpired")

    // 동시에 여러 요청이 401을 받는 경우 재발급 중복 방지
    private let tokenRefresher = TokenRefreshCoordinator()

    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        timeout: TimeInterval = 60
    ) async throws -> T {

        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = timeout

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        // 현재 저장된 Access Token 첨부
        let originalToken = UserDefaults.standard.string(
            forKey: "accessToken"
        )

        if let originalToken, !originalToken.isEmpty {
            request.setValue(
                "Bearer \(originalToken)",
                forHTTPHeaderField: "Authorization"
            )
        }

        // 최초 API 요청
        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // 정상 응답
        if (200...299).contains(httpResponse.statusCode) {
            return try JSONDecoder().decode(T.self, from: data)
        }

        // 로그인 및 토큰 재발급 요청 자체는 자동 갱신 제외
        let excludedEndpoints = [
            "/api/v1/auth/login",
            "/api/v1/auth/refresh",
            "/api/v1/users/signup"
        ]

        guard httpResponse.statusCode == 401,
              !excludedEndpoints.contains(endpoint),
              originalToken != nil
        else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        // 401 발생: 토큰 재발급
        
        do {
            let newAccessToken = try await tokenRefresher.refresh(
                baseURL: baseURL,
                failedAccessToken: originalToken!
            )

            // 기존 요청에 새 토큰 적용
            request.setValue(
                "Bearer \(newAccessToken)",
                forHTTPHeaderField: "Authorization"
            )

            // 기존 요청 한 번만 재시도
            let (retryData, retryResponse) =
                try await URLSession.shared.data(for: request)

            guard let retryHTTPResponse =
                retryResponse as? HTTPURLResponse
            else {
                throw URLError(.badServerResponse)
            }

            guard (200...299).contains(retryHTTPResponse.statusCode)
            else {
                throw APIError.serverError(
                    retryHTTPResponse.statusCode
                )
            }

            return try JSONDecoder().decode(
                T.self,
                from: retryData
            )

        } catch {
            // 실제 인증 만료가 확인된 경우에만 로그아웃
            if let authError = error as? TokenRefreshError,
               authError == .sessionExpired {

                UserDefaults.standard.removeObject(
                    forKey: "accessToken"
                )

                UserDefaults.standard.removeObject(
                    forKey: "refreshToken"
                )

                await MainActor.run {
                    NotificationCenter.default.post(
                        name: Self.authenticationExpired,
                        object: nil
                    )
                }
            }

            throw error
        }
    }
}

// MARK: - API Error

enum APIError: Error {
    case serverError(Int)
}

// MARK: - Token Refresh Error

enum TokenRefreshError: Error {
    case sessionExpired
}

// MARK: - Token Refresh Coordinator

private actor TokenRefreshCoordinator {

    private var refreshTask: Task<String, Error>?

    func refresh(
        baseURL: String,
        failedAccessToken: String
    ) async throws -> String {

        // 다른 요청이 이미 재발급 중이라면 결과 공유
        if let refreshTask {
            return try await refreshTask.value
        }

        // 다른 요청이 이미 토큰을 갱신했다면 재사용
        if let currentToken = UserDefaults.standard.string(
            forKey: "accessToken"
        ),
           currentToken != failedAccessToken,
           !currentToken.isEmpty {

            return currentToken
        }

        let task = Task<String, Error> {

            guard let refreshToken = UserDefaults.standard.string(
                forKey: "refreshToken"
            ),
                  !refreshToken.isEmpty
            else {
                throw TokenRefreshError.sessionExpired
            }

            guard let url = URL(
                string: baseURL + "/api/v1/auth/refresh"
            ) else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 60

            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )

            let refreshRequest = RefreshTokenRequest(
                refreshToken: refreshToken
            )

            request.httpBody = try JSONEncoder().encode(
                refreshRequest
            )

            let (data, response) =
                try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse
            else {
                throw URLError(.badServerResponse)
            }

            // Refresh Token 자체가 만료되었거나 무효한 경우
            if httpResponse.statusCode == 400 ||
               httpResponse.statusCode == 401 ||
               httpResponse.statusCode == 403 {

                throw TokenRefreshError.sessionExpired
            }

            guard (200...299).contains(httpResponse.statusCode)
            else {
                throw APIError.serverError(
                    httpResponse.statusCode
                )
            }

            let result = try JSONDecoder().decode(
                APIResponse<RefreshTokenResponse>.self,
                from: data
            )

            guard result.success,
                  !result.data.accessToken.isEmpty
            else {
                throw TokenRefreshError.sessionExpired
            }

            // 로그아웃이 진행된 동안 재발급 응답이 도착한 경우
            guard UserDefaults.standard.string(
                forKey: "refreshToken"
            ) == refreshToken
            else {
                throw TokenRefreshError.sessionExpired
            }

            UserDefaults.standard.set(
                result.data.accessToken,
                forKey: "accessToken"
            )

            return result.data.accessToken
        }

        refreshTask = task

        defer {
            refreshTask = nil
        }

        return try await task.value
    }
}
