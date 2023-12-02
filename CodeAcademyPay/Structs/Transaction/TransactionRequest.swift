//
//  TransactionRequest.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import Foundation

struct TransactionRequest: Codable {
    let receiver: String
    let amount: String
    let currency: String
    let description: String?
}

struct AddMoneyRequest: Codable {
    let amount: String
    let currency: String
}
