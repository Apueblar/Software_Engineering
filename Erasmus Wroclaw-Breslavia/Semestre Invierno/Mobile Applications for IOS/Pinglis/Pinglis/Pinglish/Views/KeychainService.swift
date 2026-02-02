//
//  KeychainService.swift
//  Pinglish
//

import Foundation
import Security

struct KeychainService {
    static func savePassword(_ password: String, for username: String) -> Bool {
        let account = username.lowercased()
        let service = "pinglish_auth"

        let passwordData = Data(password.utf8)

        // Si ya existe, actualizar
        if loadPassword(for: username) != nil {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [
                kSecValueData as String: passwordData
            ]
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            return status == errSecSuccess
        }

        // Si no existe, crear
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func loadPassword(for username: String) -> String? {
        let account = username.lowercased()
        let service = "pinglish_auth"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        return password
    }

    static func deletePassword(for username: String) {
        let account = username.lowercased()
        let service = "pinglish_auth"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

