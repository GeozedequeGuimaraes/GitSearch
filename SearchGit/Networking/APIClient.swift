import Foundation

class APIClient {
    static let shared = APIClient()
    
    func fetchUserProfile(for username: String, completion: @escaping (Result<GitHubUser, APIError>) -> Void) {
        guard let url = URL(string: "https://api.github.com/users/\(username)") else {
            completion(.failure(.networkError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.networkError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let user = try JSONDecoder().decode(GitHubUser.self, from: data)
                        completion(.success(user))
                    } catch {
                        completion(.failure(.networkError))
                    }
                } else {
                    completion(.failure(.networkError))
                }
            case 404:
                completion(.failure(.notFound))
            default:
                completion(.failure(.networkError))
            }
        }
        
        task.resume()
    }
    
    func fetchRepositories(for username: String, completion: @escaping (Result<[Repository], APIError>) -> Void) {
        guard let url = URL(string: "https://api.github.com/users/\(username)/repos") else {
            completion(.failure(.networkError))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(.failure(.networkError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.networkError))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let repos = try JSONDecoder().decode([Repository].self, from: data)
                        completion(.success(repos))
                    } catch {
                        completion(.failure(.networkError))
                    }
                } else {
                    completion(.failure(.networkError))
                }
            default:
                completion(.failure(.networkError))
            }
        }
        
        task.resume()
    }
}
