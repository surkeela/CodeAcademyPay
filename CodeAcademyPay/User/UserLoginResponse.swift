//
//  UserLoginResponse.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-24.
//

import Foundation

struct UserLoginResponse: Codable {
    let value: String
    let id: String
    let user: UserInfo
    let expDate: Double
    
    struct UserInfo: Codable {
        let id: String
    }
    
//    enum CodingKeys: String, CodingKey {
//        case value
//        case id
//        case user
//        case expDate
//    }
}
