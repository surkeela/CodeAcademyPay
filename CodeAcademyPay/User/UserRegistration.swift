//
//  UserRegistration.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-20.
//

import Foundation

struct UserRegistration: Codable {
    let name: String
    let password: String
    let currency: String
    let phoneNumber: String
}
