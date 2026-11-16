
import Foundation

struct UserPreferences: Codable {
    let englishLevel: String?
    let categories: [String]
}

struct PreferenceRequest: Encodable {
    let englishLevel: String
    let categories: [String]
}

final class PreferenceService {
    static let shared = PreferenceService()

    private init() {}

    func getPreferences() async throws -> UserPreferences {
        let response: APIResponse<UserPreferences> =
            try await APIClient.shared.request(
                endpoint: "/api/v1/users/me/preferences"
            )

        return response.data
    }

    func savePreferences(
        englishLevel: String,
        categories: [String]
    ) async throws {
        let request = PreferenceRequest(
            englishLevel: englishLevel,
            categories: categories
        )

        let _: APIResponse<UserPreferences> =
            try await APIClient.shared.request(
                endpoint: "/api/v1/users/me/preferences",
                method: "POST",
                body: try JSONEncoder().encode(request)
            )
    }

    func updatePreferences(
        englishLevel: String,
        categories: [String]
    ) async throws {
        let request = PreferenceRequest(
            englishLevel: englishLevel,
            categories: categories
        )

        let _: APIResponse<UserPreferences> =
            try await APIClient.shared.request(
                endpoint: "/api/v1/users/me/preferences",
                method: "PATCH",
                body: try JSONEncoder().encode(request)
            )
    }
}

