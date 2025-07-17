import Foundation

class WalkLogService: ObservableObject {
    @Published var logs: [WalkLog] = []
    private let userDefaults = UserDefaults.standard
    private let logsKey = "dogWalkLogs"

    init() {
        loadLocalLogs()
        fetchLogs()
    }

    func addLog(_ log: WalkLog) {
        logs.insert(log, at: 0)
        performRequestToSupabase(log, method: "POST")
        saveLogs()
    }

    func deleteLog(_ log: WalkLog) {
        logs.removeAll { $0.id == log.id }
        performRequestToSupabase(log, method: "DELETE")
        saveLogs()
    }

    func updateLog(_ log: WalkLog) {
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            logs[index] = log
            performRequestToSupabase(log, method: "PUT")
            saveLogs()
        }
    }

    private func saveLogs() {
        if let encoded = try? JSONEncoder().encode(logs) {
            userDefaults.set(encoded, forKey: logsKey)
        }
    }
    
    private func loadLocalLogs() {
        if let data = userDefaults.data(forKey: logsKey),
           let decodedLogs = try? JSONDecoder().decode([WalkLog].self, from: data) {
            logs = decodedLogs
        }
    }

    func getStats() -> (total: Int, good: Int, okay: Int, bad: Int) {
        let good = logs.filter { $0.walkQuality == .good }.count
        let okay = logs.filter { $0.walkQuality == .okay }.count
        let bad = logs.filter { $0.walkQuality == .bad }.count
        return (logs.count, good, okay, bad)
    }

    func saveSettings(_ userName: String) {
        userDefaults.set(userName, forKey: "userName")
    }

    func getUserName() -> String {
        return userDefaults.string(forKey: "userName") ?? "User"
    }

    func fetchLogs(force: Bool = false) {
        guard let url = URL(string: "\(SupabaseConfig.url)/rest/v1/walk_logs?select=*") else {
            print("Invalid Supabase URL")
            return
        }
        let request = makeRequest(url: url, method: "GET")
        performRequest(request, decodeAs: [WalkLog].self) { [weak self] (result: Result<[WalkLog], Error>) in
            switch result {
            case .success(let fetchedLogs):
                DispatchQueue.main.async {
                    self?.logs = fetchedLogs.sorted(by: { $0.date > $1.date })
                    self?.saveLogs()
                }
            case .failure(let error):
                print("Error fetching logs: \(error)")
            }
        }
    }
    
    private func performRequestToSupabase(_ log: WalkLog, method: String) {
        // Ensure we have a valid ID string
        let idString: String
        if let id = log.id {
            idString = id.uuidString
        } else {
            print("Error: Log ID is nil, cannot perform \(method) request")
            return
        }
        
        let urlString: String
        switch method {
        case "POST":
            urlString = "\(SupabaseConfig.url)/rest/v1/walk_logs"
        case "PUT":
            urlString = "\(SupabaseConfig.url)/rest/v1/walk_logs?id=eq.\(idString)"
        case "DELETE":
            urlString = "\(SupabaseConfig.url)/rest/v1/walk_logs?id=eq.\(idString)"
        default:
            print("Unsupported method: \(method)")
            return
        }
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for \(method) request: \(urlString)")
            return
        }
        
        var request = makeRequest(url: url, method: method)
        
        // Add required headers for DELETE operations
        if method == "DELETE" {
            request.addValue("return=minimal", forHTTPHeaderField: "Prefer")
        } else {
            do {
                request.httpBody = try makeJSONData(log)
            } catch {
                print("Encoding failed: \(error)")
                return
            }
        }
        
        performRequest(request) { (result: Result<EmptyResponse, Error>) in
            switch result {
            case .success:
                print("\(method) request to Supabase succeeded")
            case .failure(let error):
                print("\(method) request to Supabase failed: \(error.localizedDescription)")
            }
        }
    }

    private func performRequest<T: Codable>(
        _ request: URLRequest,
        decodeAs type: T.Type = EmptyResponse.self,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                let responseBody = data != nil ? String(data: data!, encoding: .utf8) ?? "No response body" : "No data"
                let errorDescription = "Invalid response with status code: \(statusCode). Response: \(responseBody)"
                print("HTTP Error: \(errorDescription)")
                let error = NSError(domain: "WalkLogService", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            // Handle EmptyResponse case
            if T.self == EmptyResponse.self {
                DispatchQueue.main.async {
                    completion(.success(EmptyResponse() as! T))
                }
                return
            }

            // For any other type, we attempt to decode
            guard let data = data else {
                let error = NSError(domain: "WalkLogService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    private func makeRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "Apikey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func makeJSONData(_ log: WalkLog) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(log)
    }
}

// Helper struct for requests that don't return data
struct EmptyResponse: Codable {
}
