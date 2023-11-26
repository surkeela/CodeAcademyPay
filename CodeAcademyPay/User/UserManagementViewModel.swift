//
//  UserManagementViewModel.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-22.
//

import Foundation

class UserManagementViewModel {
    private let networkManager = NetworkManager()

    private func performRequest<T: Decodable>(urlString: String,
                                             method: String,
                                             headers: [String: String]?,
                                             body: Data?,
                                             completion: @escaping (Result<T, Error>) -> Void) {

        guard let request = networkManager.createRequest(urlString: urlString, method: method, headers: headers, body: body) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        networkManager.performRequest(with: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(T.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func registerUser(userData: UserRegistrationData, completion: @escaping (Result<User, Error>) -> Void) {
        let urlString = Endpoints.register()
        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(userData)
            performRequest(urlString: urlString, method: "POST", headers: ["Content-Type": "application/json"], body: requestBody, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }

    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let urlString = Endpoints.allUsers()
        performRequest(urlString: urlString, method: "GET", headers: nil, body: nil, completion: completion)
    }

    private func createLoginRequest(phoneNumber: String, password: String, urlString: String) throws -> URLRequest {
        let userData = UserLoginData(phoneNumber: phoneNumber, password: password)

        let encoder = JSONEncoder()
        let requestBody = try encoder.encode(userData)

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.httpBody = requestBody

        networkManager.addBasicAuthHeader(request: &request, phoneNumber: phoneNumber, password: password)

        return request
    }

    func loginUser(phoneNumber: String, password: String, id: String, completion: @escaping (Result<UserLoginResponse, Error>) -> Void) {
        let urlString = Endpoints.login()

        do {
            let request = try createLoginRequest(phoneNumber: phoneNumber, password: password, urlString: urlString)

            networkManager.performRequest(with: request) { (result: Result<Data, NetworkError>) in
                switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    let decodingResult: Result<UserLoginResponse, Error> = Result { try decoder.decode(UserLoginResponse.self, from: data) }
                    self.handleDecodingResult(decodingResult, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }


    func fetchDataWithBearerToken(userID: String, bearerToken: String, completion: @escaping (Result<AuthenticatedUser, Error>) -> Void) {
        let urlString = Endpoints.user(withID: userID)
        let headers = ["Authorization": "Bearer \(bearerToken)"]

        performRequest(urlString: urlString, method: "GET", headers: headers, body: nil, completion: completion)
    }
    
    private func handleDecodingResult<T: Decodable>(_ decodingResult: Result<T, Error>, completion: @escaping (Result<T, Error>) -> Void) {
        switch decodingResult {
        case .success(let decodedData):
            completion(.success(decodedData))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
}

