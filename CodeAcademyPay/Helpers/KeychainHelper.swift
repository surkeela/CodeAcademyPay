//
//  KeychainHelper.swift
//  CodeAcademyPay
//
//  Created by Nerijus Surkys on 2023-12-02.
//

import Foundation
import Security

class KeychainHelper {
    
//    static func saveTokenToKeychain(token: String, forKey key: String) {
//        guard let tokenData = token.data(using: .utf8) else {
//            print("Error converting token to data")
//            return
//        }
//        
//        // Define the query to save the token securely
//        let attributes: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: key,
//            kSecValueData as String: tokenData
//        ]
//        
//        // Attempt to add the token to the keychain
//        if SecItemAdd(attributes as CFDictionary, nil) == noErr {
//            print("User saved successfully in the keychain")
//        } else {
//            print("Something went wrong trying to save the user in the keychain")
//        }
//    }
    
    static func getStringFromKeychain(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr {
            if let existingItem = item as? [String: Any],
               let keyName = existingItem[kSecAttrAccount as String] as? String,
               let data = existingItem[kSecValueData as String] as? Data,
               let value = String(data: data, encoding: .utf8)
            {
                print("Key: \(keyName)")
                print("Value: \(value)")
                return value
            }
        } else {
            print("Something went wrong trying to find the value in the keychain")
        }
        return nil
    }

    static func saveOrUpdateString(value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else {
            print("Error converting value to data")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data
        ]
        
        if SecItemCopyMatching(query as CFDictionary, nil) == noErr {
            if SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary) == noErr {
                print("Value updated successfully in the keychain")
            } else {
                print("Failed to update the value in the keychain")
            }
        } else {
            let attributesToSave: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            
            if SecItemAdd(attributesToSave as CFDictionary, nil) == noErr {
                print("Value saved successfully in the keychain")
            } else {
                print("Failed to save the value in the keychain")
            }
        }
    }

}
