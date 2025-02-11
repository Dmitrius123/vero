//
//  APIClient.swift
//  TestIOSdev
//
//  Created by Дмитрий Куприянов on 10.02.25.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL = "https://api.baubuddy.de"
    private let loginURL = "/index.php/login"
    private let credentials = "QVBJX0V4cGxvcmVyOjEyMzQ1NmlzQUxhbWVQYXNz"

    func fetchToken(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: baseURL + loginURL) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["username": "365", "password": "1"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error when receiving the token:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                let accessToken = tokenResponse.oauth.access_token
                completion(accessToken)
            } catch {
                print("Error parsing the token response:", error)
                completion(nil)
            }
        }.resume()
    }
    
    func fetchTasks(token: String, completion: @escaping ([Task]?) -> Void) {
        let urlString = "https://api.baubuddy.de/dev/index.php/v1/tasks/select"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error when fetching tasks:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }

            // Печать необработанного ответа
            if let responseData = String(data: data, encoding: .utf8) {
                print("Server response:", responseData)
            }

            do {
                let tasks = try JSONDecoder().decode([Task].self, from: data)
                completion(tasks)
            } catch {
                print("Error decoding tasks:", error)
                completion(nil)
            }
        }.resume()
    }
}

struct TokenResponse: Codable {
    struct OAuth: Codable {
        let access_token: String
    }
    let oauth: OAuth
}
