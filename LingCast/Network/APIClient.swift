
import Foundation

final class APIClient {

    static let shared = APIClient()

    private init() {}

    // Spring Boot 서버 주소
    private let baseURL = "http://localhost:8080"

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

        // 요청별 타임아웃 설정
        request.timeoutInterval = timeout

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        // 저장된 Access Token이 있으면 인증 헤더에 자동 추가
        if let accessToken = UserDefaults.standard.string(
            forKey: "accessToken"
        ) {
            request.setValue(
                "Bearer \(accessToken)",
                forHTTPHeaderField: "Authorization"
            )
        }

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum APIError: Error {
    case serverError(Int)
}

