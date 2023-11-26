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
    case decodingError(Error)
    case authenticationError
}

class NetworkManager {
    func performRequest<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    func createRequest(urlString: String, method: String, headers: [String: String]?, body: Data?) throws -> URLRequest {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
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
    
}


