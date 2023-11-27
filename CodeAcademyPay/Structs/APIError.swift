//
//  APIError.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-27.
//

import Foundation

struct APIError: Error {
    let error: Bool
    let reason: String
    
    init(error: Bool, reason: String) {
        self.error = error
        self.reason = reason
    }
}
