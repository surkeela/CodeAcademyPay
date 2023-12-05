//
//  Transaction+CoreDataProperties.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-29.
//
//

import Foundation
import CoreData

extension Transaction {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }
    
    @NSManaged public var amount: String?
    @NSManaged public var id: String?
    @NSManaged public var receiver: String?
    @NSManaged public var sender: String?
    @NSManaged public var currency: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var transactionDescription: String?
    @NSManaged public var userResponseId: String?
    
}

extension Transaction : Identifiable {
    func update(with transactionResponse: TransactionResponse) {
        self.amount = transactionResponse.amount
        self.id = transactionResponse.id
        self.receiver = transactionResponse.receiver
        self.sender = transactionResponse.sender
        self.currency = transactionResponse.currency
        self.createdAt = transactionResponse.createdAt
        self.transactionDescription = transactionResponse.description
        self.userResponseId = transactionResponse.user.id
    }
    
}

extension Transaction {
    func matchesSearchQuery(_ searchText: String) -> Bool {
        guard let transactionDescription = self.transactionDescription?.lowercased(),
              let phoneNumber = (self.receiver ?? self.sender)?.lowercased() else {
            return false
        }
        
        let text = searchText.lowercased()

        if transactionDescription.localizedCaseInsensitiveContains(text) || phoneNumber.localizedCaseInsensitiveContains(text) {
            return true
        }
        
        return false
    }
}
