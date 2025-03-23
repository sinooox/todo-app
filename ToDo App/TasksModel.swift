import Foundation

struct Task: Identifiable, Decodable {
    let id: Int
    let note: String
}

enum AlertType: Identifiable {
    case error(String)
    case deleteSuccess
    case addSuccess
    case fetchSuccess

    var id: Int {
        switch self {
        case .error: return 0
        case .deleteSuccess: return 1
        case .addSuccess: return 2
        case .fetchSuccess: return 3
        }
    }
}

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var alertType: AlertType?
    @Published var isManualRefresh = false

    func fetchTasks(login: String, password: String) {
        guard let url = URL(string: "http://217.71.129.139:5428/notes") else {
            alertType = .error("Ошибка: некорректный URL")
            return
        }
        let credentials = "\(login):\(password)"
        guard let credentialData = credentials.data(using: .utf8) else {
            alertType = .error("Ошибка кодирования учетных данных")
            return
        }
        let encodedCredentials = credentialData.base64EncodedString()
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertType = .error(
                        "Ошибка сети: \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.alertType = .error("Ошибка: нет HTTP-ответа")
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.alertType = .error(
                        "Ошибка HTTP: код \(httpResponse.statusCode)")
                    return
                }
                guard let data = data else {
                    self.alertType = .error("Ошибка: нет данных в ответе")
                    return
                }
                do {
                    let decodedTasks = try JSONDecoder().decode(
                        [Task].self, from: data)
                    self.tasks = decodedTasks
                    if self.isManualRefresh {
                        self.alertType = .fetchSuccess
                        self.isManualRefresh = false
                    }
                } catch {
                    self.alertType = .error(
                        "Ошибка декодирования JSON: \(error.localizedDescription)"
                    )
                }
            }
        }.resume()
    }

    func addTask(note: String, login: String, password: String) {
        guard let url = URL(string: "http://217.71.129.139:5428/notes") else {
            alertType = .error("Ошибка: некорректный URL")
            return
        }
        let credentials = "\(login):\(password)"
        guard let credentialData = credentials.data(using: .utf8) else {
            alertType = .error("Ошибка кодирования учетных данных")
            return
        }
        let encodedCredentials = credentialData.base64EncodedString()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["note": note]
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            alertType = .error(
                "Ошибка при подготовке данных: \(error.localizedDescription)")
            return
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertType = .error(
                        "Ошибка сети: \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.alertType = .error("Ошибка: нет HTTP-ответа")
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.alertType = .error(
                        "Ошибка HTTP: код \(httpResponse.statusCode)")
                    return
                }
                self.fetchTasks(login: login, password: password)
                self.alertType = .addSuccess
            }
        }.resume()
    }

    func deleteTask(noteID: Int, login: String, password: String) {
        guard
            let url = URL(string: "http://217.71.129.139:5428/notes/\(noteID)")
        else {
            alertType = .error("Ошибка: некорректный URL")
            return
        }
        let credentials = "\(login):\(password)"
        guard let credentialData = credentials.data(using: .utf8) else {
            alertType = .error("Ошибка кодирования учетных данных")
            return
        }
        let encodedCredentials = credentialData.base64EncodedString()
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(
            "Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertType = .error(
                        "Ошибка сети: \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.alertType = .error("Ошибка: нет HTTP-ответа")
                    return
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.alertType = .error(
                        "Ошибка HTTP: код \(httpResponse.statusCode)")
                    return
                }
                self.fetchTasks(login: login, password: password)
                self.alertType = .deleteSuccess
            }
        }.resume()
    }
}
