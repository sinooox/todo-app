import Foundation

struct RegisterResponse: Codable {
    let message: String
}

func registerUser(
    login: String, password: String,
    completion: @escaping (Result<String, Error>) -> Void
) {
    guard let url = URL(string: "http://217.71.129.139:5428/register") else {
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

        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion(
                    .failure(
                        NSError(
                            domain: "InvalidResponse", code: 500, userInfo: nil)
                    ))
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
            let registerResponse = try decoder.decode(
                RegisterResponse.self, from: data)

            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(.success(registerResponse.message))
                }
            } else {
                DispatchQueue.main.async {
                    completion(
                        .failure(
                            NSError(
                                domain: "ServerError",
                                code: httpResponse.statusCode,
                                userInfo: [
                                    NSLocalizedDescriptionKey: registerResponse
                                        .message
                                ])))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    task.resume()
}
