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
        guard let tokenData = token.data(using: .utf8) else {
            print("Error converting token to data")
            return
        }
        
        // Define the query to save the token securely
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData
        ]
        
        // Attempt to add the token to the keychain
        if SecItemAdd(attributes as CFDictionary, nil) == noErr {
            print("User saved successfully in the keychain")
        } else {
            print("Something went wrong trying to save the user in the keychain")
        }
    }
    
    static func getTokenFromKeychain(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        // Check if user exists in the keychain
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            // Extract result
            if let existingItem = item as? [String: Any],
               let keyName = existingItem[kSecAttrAccount as String] as? String,
               let tokenData = existingItem[kSecValueData as String] as? Data,
               let token = String(data: tokenData, encoding: .utf8)
            {
                print("Key: \(keyName)")
                print("Token: \(token)")
                return token
            }
        } else {
            print("Something went wrong trying to find the token in the keychain")
        }
        return nil
    }
    
    static func updateTokenInKeychain(newToken: String, forKey key: String) {
        guard let tokenData = newToken.data(using: .utf8) else {
            print("Error converting token to data")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: tokenData
        ]
        
        // Update token if it exists
        if SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary) == noErr {
            print("Token updated successfully in the keychain")
        } else {
            print("Token update failed or token does not exist in the keychain")
        }
    }
    
    static func saveOrUpdateToken(token: String, forKey key: String) {
        guard let tokenData = token.data(using: .utf8) else {
            print("Error converting token to data")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: tokenData
        ]
        
        // Check if the token exists
        if SecItemCopyMatching(query as CFDictionary, nil) == noErr {
            // Token exists, update it
            if SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary) == noErr {
                print("Token updated successfully in the keychain")
            } else {
                print("Failed to update the token in the keychain")
            }
        } else {
            // Token doesn't exist, save it
            let attributesToSave: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: tokenData
            ]
            
            if SecItemAdd(attributesToSave as CFDictionary, nil) == noErr {
                print("Token saved successfully in the keychain")
            } else {
                print("Failed to save the token in the keychain")
            }
        }
    }
}
