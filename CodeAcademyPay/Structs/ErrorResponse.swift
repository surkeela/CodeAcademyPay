//
//  ErrorResponse.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-11-28.
//

import Foundation

struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}
