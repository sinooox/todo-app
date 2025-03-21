import Foundation

struct AuthResponse: Codable {
    let message: String
    let user_id: Int
}

func loginUser(
    login: String, password: String,
    completion: @escaping (Result<AuthResponse, Error>) -> Void
) {
    guard let url = URL(string: "http://217.71.129.139:5428/login") else {
        DispatchQueue.main.async {
            completion(
                .failure(
                    NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
        }
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
        "login": login,
        "password": password,
    ]

    do {
        let jsonData = try JSONSerialization.data(
            withJSONObject: body, options: [])
        request.httpBody = jsonData
    } catch {
        DispatchQueue.main.async {
            completion(.failure(error))
        }
        return
    }

    let task = URLSession.shared.dataTask(with: request) {
        data, response, error in
        if let error = error {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        guard let data = data else {
            DispatchQueue.main.async {
                completion(
                    .failure(
                        NSError(domain: "NoData", code: 404, userInfo: nil)))
            }
            return
        }

        do {
            let decoder = JSONDecoder()
            let authResponse = try decoder.decode(AuthResponse.self, from: data)
            DispatchQueue.main.async {
                completion(.success(authResponse))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    task.resume()
}
