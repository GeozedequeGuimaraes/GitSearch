import Foundation

enum APIError: Error {
    case networkError
    case notFound
    
    var localizedDescription: String {
        switch self {
        case .networkError:
            return "A network error has occurred. Check your Internet connection and try again later."
        case .notFound:
            return "User not found. Please enter another name."
        }
    }
}
