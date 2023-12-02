//
//  KeychainHelper.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-12-02.
//

import Foundation
import Security

class KeychainHelper {
    
    static func saveTokenToKeychain(token: String, forKey key: String) {
        guard let data = token.data(using: .utf8) else {
            print("Error converting token to data")
            return
        }

        // Define the query to save the token securely
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked // Adjust accessibility as needed
        ]

        // Attempt to add the token to the keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving token to keychain")
        }
    }
    
    static func getTokenFromKeychain(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var tokenData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &tokenData)

        if status == errSecSuccess, let retrievedData = tokenData as? Data {
            if let token = String(data: retrievedData, encoding: .utf8) {
                return token
            }
        } else {
            print("Error retrieving token from keychain")
        }

        return nil
    }
    
}
