//
//  TransactionViewModel.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import Foundation

class TransactionViewModel {
    let networkManager = NetworkManager()

    func createTransaction(receiver: String, amount: String, currency: String, description: String, bearerToken: String, completion: @escaping (Result<TransactionResponse, Error>) -> Void) {
        let urlString = Endpoints.createTransaction()
        let requestBody = TransactionRequest(receiver: receiver, amount: amount, currency: currency, description: description)
        let headers = ["Authorization": "Bearer \(bearerToken)", "Content-Type": "application/json"]

        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            let request = try networkManager.createRequest(urlString: urlString, method: "POST", headers: headers, body: jsonData)
            
            networkManager.performRequest(with: request){ (result: Result<TransactionResponse, NetworkError>) in
                switch result {
                case .success(let transaction):
                    completion(.success(transaction))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
