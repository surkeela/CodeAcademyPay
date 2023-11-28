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
    case apiError(String)
    case decodingError(Error)
    case authenticationError
}

class NetworkManager {
    typealias CompletionHandler<T: Decodable> = (Result<T, NetworkError>) -> Void
    typealias ErrorHandler = (String) -> Void
    
    func performRequest<T: Decodable>(with request: URLRequest, completion: @escaping CompletionHandler<T>, errorHandler: @escaping ErrorHandler) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.decodingError(error)))
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
                // Attempt to decode error response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data), errorResponse.error {
                    errorHandler(errorResponse.reason)
                    completion(.failure(.apiError(errorResponse.reason)))
                } else {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
    
    func createRequest(urlString: String, method: String, headers: [String: String]?, body: Data?) throws -> URLRequest {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let headers = headers {
            headers.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpBody = body
        
        return request
    }
    
    func createBasicAuthRequest(phoneNumber: String, password: String, urlString: String) throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Add Basic Authentication Header
        let loginString = "\(phoneNumber):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            throw NetworkError.authenticationError
        }
        
        let base64LoginString = loginData.base64EncodedString()
        let authString = "Basic \(base64LoginString)"
        request.setValue(authString, forHTTPHeaderField: "Authorization")

        return request
    }
    
}
