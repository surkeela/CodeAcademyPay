//
//  NetworkManager.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-20.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case networkError(Error)
}

class NetworkManager {
    private var authToken: String?

    func createRequest(urlString: String, method: String, headers: [String: String]?, body: Data?) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        request.httpBody = body

        return request
    }

    func addBasicAuthHeader(request: inout URLRequest, phoneNumber: String, password: String) {
        let loginString = "\(phoneNumber):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            return
        }

        let base64LoginString = loginData.base64EncodedString()
        let authString = "Basic \(base64LoginString)"
        request.setValue(authString, forHTTPHeaderField: "Authorization")
    }

    func performRequest(with request: URLRequest, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            completion(.success(data))
        }.resume()
    }

}

