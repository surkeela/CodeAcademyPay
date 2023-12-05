//
//  TransactionViewModel.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import UIKit
import CoreData

class TransactionViewModel {
    private let networkManager = NetworkManager()
    private let userManagementViewModel = UserManagementViewModel()
    
    private func retrieveToken() -> String? {
        KeychainHelper.getStringFromKeychain(forKey: "Bearer_token")
    }
    
    func createTransaction(receiver: String, amount: String, currency: String, description: String?, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<TransactionResponse, Error>) -> Void) {
        if let retrievedToken = retrieveToken() {
            let urlString = Endpoints.createTransaction()
            let jsonData = TransactionRequest(receiver: receiver, amount: amount, currency: currency, description: description)
            let headers = ["Authorization": "Bearer \(retrievedToken)", "Content-Type": "application/json"]
            
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
        } else {
            print("Token not found in keychain")
        }
    }
    
    func fetchAllTransactions(userID: String, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<[TransactionResponse], Error>) -> Void) {
        if let retrievedToken = retrieveToken() {
            let urlString = Endpoints.getTransactions(withID: userID)
            let headers = ["Authorization": "Bearer \(retrievedToken)"]
            
            do {
                let request = try networkManager.createRequest(urlString: urlString, method: "GET", headers: headers, body: nil)
                
                networkManager.performRequest(with: request, completion: { (result: Result<[TransactionResponse], NetworkError>) in
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
        } else {
            print("Token not found in keychain")
        }
    }
    
    func saveTransactionsToCoreData(transactionResponses: [TransactionResponse], currentUserID: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for transactionResponse in transactionResponses {
            let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", transactionResponse.id )
            
            do {
                if let existingTransaction = try context.fetch(fetchRequest).first {
                    existingTransaction.update(with: transactionResponse)
                } else {
                    let newTransaction = Transaction(context: context)
                    newTransaction.update(with: transactionResponse)
                    newTransaction.userResponseId = transactionResponse.user.id
                }
            } catch {
                print("Error during fetch or update in Core Data")
            }
        }
        
        do {
            try context.save()
            print("Successfully saved to Core Data")
        } catch {
            print("Error during save to Core Data")
        }
    }
    
    func addMoneyTransaction(amount: String, currency: String, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        if let retrievedToken = retrieveToken() {
            let urlString = Endpoints.addMoney()
            let jsonData = AddMoneyRequest(amount: amount, currency: currency)
            let headers = ["Authorization": "Bearer \(retrievedToken)", "Content-Type": "application/json"]
            
            do {
                let requestBody = try JSONEncoder().encode(jsonData)
                let request = try networkManager.createRequest(urlString: urlString, method: "POST", headers: headers, body: requestBody)
                
                networkManager.performRequestAddMoney(with: request, errorHandler: errorHandler)
            } catch {
                completion(.failure(error))
            }
        } else {
            print("Token not found in keychain")
        }
    }
    
}
