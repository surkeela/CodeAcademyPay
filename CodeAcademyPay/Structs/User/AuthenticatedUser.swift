//
//  AuthenticatedUser.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-23.
//

import Foundation

struct AuthenticatedUser: Codable {
    var currency: String
    var balance: Double
    let name: String
    let phoneNumber: String
    let id: String
}
