//
//  UserManagementViewModel.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-22.
//

import Foundation

class UserManagementViewModel {
    
    private let networking = Networking()
    
    func registerUser(userData: UserRegistration, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = Endpoints.register()
        
        let jsonData: [String: Any] = [
            "name": userData.name,
            "password": userData.password,
            "currency": userData.currency,
            "phoneNumber": userData.phoneNumber
        ]
        
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: jsonData)
            
            guard let request = networking.createRequest(urlString: urlString, method: "POST", headers: ["Content-Type": "application/json"], body: requestBody) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            networking.performRequest(with: request) { result in
                switch result {
                case .success(let data):
                    if let responseString = String(data: data, encoding: .utf8) {
                        completion(.success(responseString))
                    } else {
                        completion(.failure(NetworkError.noData))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(NetworkError.serializationError(error)))
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let urlString = Endpoints.allUsers()
        
        guard let request = networking.createRequest(urlString: urlString, method: "GET", headers: nil, body: nil) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        networking.performRequest(with: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let users = try decoder.decode([User].self, from: data)
                    completion(.success(users))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
