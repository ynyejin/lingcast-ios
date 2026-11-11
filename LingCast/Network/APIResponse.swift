import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let message: String
    let code: String?
}
