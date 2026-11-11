import Foundation

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int64
}
