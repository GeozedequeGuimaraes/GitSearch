import Foundation

struct GitHubUser: Codable {
    let login: String
    let name: String?
    let avatar_url: String
}
