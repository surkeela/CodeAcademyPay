//
//  AuthenticationManager.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-22.
//

import Foundation

class AuthenticationManager {
    
    func validatePhoneNumber(phoneNumber: String) -> Bool {
        guard !phoneNumber.isEmpty else {
            return false
        }
        
        let numericExpression = "[0-9]{9,}"
        let numericPredicate = NSPredicate(format: "SELF MATCHES %@", numericExpression)
        return numericPredicate.evaluate(with: phoneNumber)
    }
    
}
