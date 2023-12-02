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
    
    func createTransaction(receiver: String, amount: String, currency: String, description: String?, bearerToken: String, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<TransactionResponse, Error>) -> Void) {
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
    
    func fetchAllTransactions(bearerToken: String, userID: String, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<[TransactionResponse], Error>) -> Void) {
        let urlString = Endpoints.getTransactions(withID: userID)
        let headers = ["Authorization": "Bearer \(bearerToken)"]
        
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
    }
    
     func saveTransactionsToCoreData(transactionResponses: [TransactionResponse], currentUserID: String) {
         let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
         
         for transactionResponse in transactionResponses {
             let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
             fetchRequest.predicate = NSPredicate(format: "id == %@", transactionResponse.id ?? "")
             
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
    
    func addMoneyTransaction(amount: String, currency: String, bearerToken: String, errorHandler: @escaping (String) -> Void, completion: @escaping (Result<Bool, Error>) -> Void) {
        let urlString = Endpoints.addMoney()
        let jsonData = AddMoneyRequest(amount: amount, currency: currency)
        let headers = ["Authorization": "Bearer \(bearerToken)", "Content-Type": "application/json"]
        
        do {
            let requestBody = try JSONEncoder().encode(jsonData)
            let request = try networkManager.createRequest(urlString: urlString, method: "POST", headers: headers, body: requestBody)
            
            networkManager.performRequest(with: request, completion: { (result: Result<Bool, NetworkError>) in
                switch result {
                case .success(let transaction):
                    completion(.success(transaction))
                case .failure(let error):
                    completion(.failure(error))
                }
            }, errorHandler: errorHandler)
        } catch {
            completion(.failure(error))
        }
    }
    
}
