//
//  ValidationHelper.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-28.
//

import Foundation

class ValidationHelper {
    
    static func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegex = #"^\d{9,}$"#
        return NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: phoneNumber)
    }
    
    static func isValidCurrency(_ currency: String) -> Bool {
        let currencyRegex = #"^[A-Z]{3}$"#
        return NSPredicate(format: "SELF MATCHES %@", currencyRegex).evaluate(with: currency)
    }
    
}
