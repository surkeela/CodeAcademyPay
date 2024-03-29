//
//  Endpoints.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-20.
//

import Foundation

struct Endpoints {
    static let base = "https://codeacademypay.fly.dev/api/"
    
    static func getAllUsers() -> String {
        Endpoints.base + "users"
    }
    
    static func register() -> String {
        Endpoints.base + "users/register"
    }
    
    static func login() -> String {
        Endpoints.base + "users/login"
    }
    
    static func getUser(withID userID: String) -> String {
        return base + "users/\(userID)"
    }
    
    static func updateAuth() -> String{
        return base + "users/update"
    }
    
    static func createTransaction() -> String {
        Endpoints.base + "transactions/create"
    }
    
    static func getTransactions(withID userID: String) -> String {
        Endpoints.base + "transactions/\(userID)"
    }
    
    static func addMoney() -> String {
        Endpoints.base + "transactions/add"
    }
    
}
