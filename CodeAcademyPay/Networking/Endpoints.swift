//
//  Endpoints.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-20.
//

import Foundation

struct Endpoints {
    static let base = "https://codeacademypay.fly.dev/api/"
    
    static func allUsers() -> String {
        Endpoints.base + "users"
    }
    
    static func register() -> String {
        Endpoints.base + "users/register"
    }
    
    static func login() -> String {
        Endpoints.base + "users/login"
    }
    
    static func user(withID userID: String) -> String {
        return base + "users/\(userID)"
    }
    
    static func createTransaction() -> String {
        Endpoints.base + "transactions/create"
    }
    
    static func getTransactions(withID userID: String) -> String {
        Endpoints.base + "transactions/\(userID)"
    }
    
}
