//
//  TransactionViewModel.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import Foundation

class TransactionViewModel {
    let networkManager = NetworkManager()
    
    func createTransaction(receiver: String, amount: String, currency: String, description: String, bearerToken: String, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<TransactionResponse, Error>) -> Void) {
        let urlString = Endpoints.createTransaction()
        let jsonData = TransactionRequest(receiver: receiver, amount: amount, currency: currency, description: description)
        let headers = ["Authorization": "Bearer \(bearerToken)", "Content-Type": "application/json"]
        
        do {
            let requestBody = try JSONEncoder().encode(jsonData)
            let request = try networkManager.createRequest(urlString: urlString, method: "POST", headers: headers, body: requestBody)
            
            networkManager.performRequest(with: request, completion: { (result: Result<TransactionResponse, NetworkError>) in
                switch result {
                case .success(let transaction):
                    completion(.success(transaction))
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
        }
    }
    
}
