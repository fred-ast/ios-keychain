//
//  KeychainManager.swift
//  ios-Keychain
//
//  Created by Frédéric ASTIC on 09/08/2021.
//

import Foundation
import Security

enum KeychainStorableKey: String, CaseIterable {
    case deviceId
    case email
    case refreshToken
    // ... 
}

class KeychainManager {
    
    private struct Constant {
        static let prefixKey: String = "org.fast.ios-keychain" 
    }
    
    class var deviceIdentifier: String {
        guard let uniqueId = string(.deviceId) else {
            //new install 
            let newId = UUID().uuidString
            set(newId, key: .deviceId)
            return newId
        }
        return uniqueId
    }
    
    @discardableResult
    class func string(_ key: KeychainStorableKey, accessGroup: String? = nil) -> String? {
        guard let dataValue = get(key: keyId(key), accessGroup: accessGroup) else {
            return nil
        }
        return String(data: dataValue, encoding: .utf8)
    }
 
    @discardableResult
    class func set(_ value: String, key: KeychainStorableKey, accessGroup: String? = nil) -> Bool {
        guard let dataValue = value.data(using: .utf8) else {
            return false
        }
        return set(data: dataValue, key: keyId(key), accessGroup: accessGroup)
    }
    
    @discardableResult
    class func remove(_ key: KeychainStorableKey, accessGroup: String? = nil) -> Bool {
        return remove(key: keyId(key))
    }
    
    @discardableResult
    class func clear(accessGroup: String? = nil) -> Bool {
        var success = true
        _ = KeychainStorableKey.allCases.compactMap { (key) in
            if !(remove(key, accessGroup: accessGroup)) {
                success = false
            }
        }
        return success
    }
    
    private class func keyId(_ key: KeychainStorableKey) -> String {
        return "\(Constant.prefixKey).keychain.\(key.rawValue)"
    }
    
    private class func set(data: Data, key: String, accessGroup: String? = nil) -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        if let accessGroupValue = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroupValue
        }
        remove(key: key)
        var dataTypeRef: AnyObject? 
        let result =  SecItemAdd(query as CFDictionary, &dataTypeRef)
        
        return result == errSecSuccess
    }
    
    private class func get(key: String, accessGroup: String? = nil) -> Data? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as CFBoolean,
            kSecMatchLimit as String: kSecMatchLimitOne]
        if let accessGroupValue = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroupValue
        }
        
        var dataTypeRef: AnyObject? 
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == noErr else {
            return nil
        } 
        return dataTypeRef as? Data
    }
    
    @discardableResult
    private class func remove(key: String, accessGroup: String? = nil) -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key
        ]
        if let accessGroupValue = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroupValue
        }
        
        return SecItemDelete(query as CFDictionary) == noErr
    }
}
