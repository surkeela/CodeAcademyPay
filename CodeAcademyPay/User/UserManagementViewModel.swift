//
//  UserManagementViewModel.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-22.
//

import Foundation

class UserManagementViewModel {
    private let networking = Networking()
    
    func registerUser(userData: UserRegistrationData, completion: @escaping (Result<User, Error>) -> Void) {
        let urlString = Endpoints.register()
        
        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(userData)
            
            guard let request = networking.createRequest(urlString: urlString, method: "POST", headers: ["Content-Type": "application/json"], body: requestBody) else {
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            networking.performRequest(with: request) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let user = try decoder.decode(User.self, from: data)
                        completion(.success(user))
                    } catch {
                        completion(.failure(NetworkError.serializationError(error)))
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
    
    func fetchAuthenticatedUser(userID: String, authToken: String, completion: @escaping (Result<AuthenticatedUser, NetworkError>) -> Void) {
        let urlString = Endpoints.base + userID
        guard let request = networking.createRequest(urlString: urlString, method: "GET", headers: ["Authorization": "Bearer \(authToken)"], body: nil) else {
            completion(.failure(.invalidURL))
            return
        }

        networking.performRequest(with: request) { result in
            switch result {
            case .success(let data):
                print(String(data: data, encoding: .utf8))
                do {
                    let decoder = JSONDecoder()
                    let user = try decoder.decode(AuthenticatedUser.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(.serializationError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
