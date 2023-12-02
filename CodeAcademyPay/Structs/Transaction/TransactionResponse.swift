//
//  TransactionResponse.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import Foundation

struct TransactionResponse: Codable {
    let receiver: String
    let amount: String
    let description: String?
    let id: String
    let sender: String?
    let currency: String
    let user: UserResponse
    let createdAt: String
}

struct UserResponse: Codable {
    let id: String?
}
