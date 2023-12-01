//
//  HomeViewModel.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-30.
//

import UIKit
import CoreData

class HomeViewModel {
    private let transactionViewModel = TransactionViewModel()
    private var currentUser: AuthenticatedUser
    var allTransactions: [Transaction] = []

    init(currentUser: AuthenticatedUser) {
        self.currentUser = currentUser
    }

    func fetchTransactions() {
        guard let token = UserDefaults.standard.string(forKey: "UserToken") else { return }
        let userID = currentUser.id
        
        transactionViewModel.fetchAllTransactions(
            bearerToken: token,
            userID: userID,
            errorHandler: { errorMessage in
                // Handle error message
            },
            completion: { [weak self] result in
                switch result {
                case .success(let transactions):
                    self?.saveTransactionsToCoreData(transactionResponses: transactions, currentUserID: userID)
                case .failure(let error):
                    print("Failed to fetch transactions: \(error)")
                }
            }
        )
    }

    func fetchTransactionsForUser() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userResponseId == %@", currentUser.id)
        
        do {
            let transactions = try context.fetch(fetchRequest)
            allTransactions = transactions
            // Notify the view controller that data is ready to be displayed
        } catch {
            print("Error fetching transactions for user \(currentUser.id): \(error)")
        }
    }

    private func saveTransactionsToCoreData(transactionResponses: [TransactionResponse], currentUserID: String) {
        DispatchQueue.main.async {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            for transactionResponse in transactionResponses {
                let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", transactionResponse.id)
                
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
    }
    
}
