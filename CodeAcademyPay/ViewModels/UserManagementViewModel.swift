//
//  UserManagementViewModel.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-22.
//

import Foundation

class UserManagementViewModel {
    private let networkManager = NetworkManager()

    func registerUser(userData: UserRegistrationData, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<User, Error>) -> Void) {
        let urlString = Endpoints.register()
        let headers = ["Content-Type": "application/json"]
        
        do {
            let requestBody = try JSONEncoder().encode(userData)
            let request = try networkManager.createRequest(urlString: urlString, method: "POST", headers: headers, body: requestBody)
            
            networkManager.performRequest(with: request, completion: { (result: Result<User, NetworkError>) in
                switch result {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    switch error {
                    case .apiError(let reason):
                        errorHandler(reason)
                    default:
                        errorHandler("An error occurred")
                    }
                    completion(.failure(error))
                }
            }, errorHandler: errorHandler)
        } catch {
            completion(.failure(error))
            print("🟥🟥 catch \(error.localizedDescription)")
        }
    }

    func getAllUsers(errorHandler: @escaping (String) -> Void, completion: @escaping (Result<[User], Error>) -> Void) {
        let urlString = Endpoints.allUsers()
        
        do {
            let request = try networkManager.createRequest(urlString: urlString, method: "GET", headers: nil, body: nil)
            
            networkManager.performRequest(with: request, completion: { (result: Result<[User], NetworkError>) in
                switch result {
                case .success(let users):
                    completion(.success(users))
                case .failure(let error):
                    switch error {
                    case .apiError(let reason):
                        errorHandler(reason)
                    default:
                        errorHandler("An error occurred")
                    }
                    completion(.failure(error))
                }
            }, errorHandler: errorHandler)
        } catch {
            completion(.failure(error))
            print("🟥🟥 catch \(error.localizedDescription)")
        }
    }

    func createLoginRequest(phoneNumber: String, password: String, urlString: String) throws -> URLRequest {
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

    func loginUser(phoneNumber: String, password: String, id: String, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<UserLoginResponse, Error>) -> Void) {
        let urlString = Endpoints.login()

        do {
            let request = try createLoginRequest(phoneNumber: phoneNumber, password: password, urlString: urlString)

            networkManager.performRequest(with: request, completion: { (result: Result<UserLoginResponse, NetworkError>) in
                switch result {
                case .success(let userLoginResponse):
                    completion(.success(userLoginResponse))
                case .failure(let error):
                    switch error {
                    case .apiError(let reason):
                        errorHandler(reason)
                    default:
                        errorHandler("An error occurred")
                    }
                    completion(.failure(error))
                }
            }, errorHandler: errorHandler)
        } catch {
            completion(.failure(error))
            print("🟥🟥 catch \(error.localizedDescription)")
        }
    }

    func fetchDataWithBearerToken(userID: String, bearerToken: String, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<AuthenticatedUser, Error>) -> Void) {
        let urlString = Endpoints.user(withID: userID)
        let headers = ["Authorization": "Bearer \(bearerToken)"]

        do {
            let request = try networkManager.createRequest(urlString: urlString, method: "GET", headers: headers, body: nil)

            networkManager.performRequest(with: request, completion: { (result: Result<AuthenticatedUser, NetworkError>) in
                switch result {
                case .success(let authenticatedUser):
                    completion(.success(authenticatedUser))
                case .failure(let error):
                    switch error {
                    case .apiError(let reason):
                        errorHandler(reason)
                    default:
                        errorHandler("An error occurred")
                    }
                    completion(.failure(error))
                }
            }, errorHandler: errorHandler)
        } catch {
            completion(.failure(error))
            print("🟥🟥 catch \(error.localizedDescription)")
        }
    }
    
}

