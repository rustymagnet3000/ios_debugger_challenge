import Security
import Foundation

/* Reference: https://github.com/trailofbits/SecureEnclaveCrypto/SecureEnclaveHelper.swift */

struct SecureEnclaveHelperError: Error {
    
    let message: String
    let osStatus: OSStatus?
    let link: String
    
    init(message: String, osStatus: OSStatus?) {
        
        self.message = message
        self.osStatus = osStatus
        
        if let code = osStatus {
            link = "https://www.osstatus.com/search/results?platform=all&framework=Security&search=\(code)"
        }
        else {
            
            link = ""
        }
    }
}

final class SecureEnclaveKeyData {
    
    let underlying: [String: Any]
    let ref: SecureEnclaveKeyReference
    let data: Data
    
    fileprivate init(_ underlying: CFDictionary) {
        
        let converted = underlying as! [String: Any]
        self.underlying = converted
        self.data = converted[kSecValueData as String] as! Data
        self.ref = SecureEnclaveKeyReference(converted[kSecValueRef as String] as! SecKey)
    }
    
    var hex: String {
        
        return self.data.map { String(format: "%02hhx", $0) }.joined()
    }
}

final class SecureEnclaveKeyReference {
    
    let underlying: SecKey
    
    fileprivate init(_ underlying: SecKey) {
        
        self.underlying = underlying
    }
}

class YDHammertime {

    let publicLabel: String
    let privateLabel: String
    let operationPrompt: String
    
    init(publicLabel: String, privateLabel: String, operationPrompt: String) {
        
        self.publicLabel = publicLabel
        self.privateLabel = privateLabel
        self.operationPrompt = operationPrompt
    }


    func generateKeyPair(accessControl: SecAccessControl) throws -> (`public`: SecureEnclaveKeyReference, `private`: SecureEnclaveKeyReference) {
        
        let privateKeyParams: [String: Any] = [
            kSecAttrLabel as String: privateLabel,
            kSecAttrIsPermanent as String: true,
            kSecAttrAccessControl as String: accessControl,
            ]
        let params: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: privateKeyParams
        ]
        var publicKey, privateKey: SecKey?
        
        let status = SecKeyGeneratePair(params as CFDictionary, &publicKey, &privateKey)
        
        guard status == errSecSuccess else {
            
            throw SecureEnclaveHelperError(message: "Could not generate keypair", osStatus: status)
        }
        
        return (public: SecureEnclaveKeyReference(publicKey!), private: SecureEnclaveKeyReference(privateKey!))
    }
    
    func accessControl(with protection: CFString = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, flags: SecAccessControlCreateFlags = [.userPresence, .privateKeyUsage]) throws -> SecAccessControl {
        
        var accessControlError: Unmanaged<CFError>?
        
        let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, protection, flags, &accessControlError)
        
        guard accessControl != nil else {
            
            throw SecureEnclaveHelperError(message: "Could not generate access control. Error \(accessControlError?.takeRetainedValue())", osStatus: nil)
        }
        
        return accessControl!
    }
    
    func getPublicKey() throws -> SecureEnclaveKeyData {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: attrKeyTypeEllipticCurve,
            kSecAttrApplicationTag as String: publicLabel,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnData as String: true,
            kSecReturnRef as String: true,
            kSecReturnPersistentRef as String: true,
            ]
        
        let raw = try getSecKeyWithQuery(query)
        return SecureEnclaveKeyData(raw as! CFDictionary)
    }
    
    func forceSavePublicKey(_ publicKey: SecureEnclaveKeyReference) throws {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: attrKeyTypeEllipticCurve,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag as String: publicLabel,
            kSecValueRef as String: publicKey.underlying,
            kSecAttrIsPermanent as String: true,
            kSecReturnData as String: true,
            ]
        
        var raw: CFTypeRef?
        var status = SecItemAdd(query as CFDictionary, &raw)
        
        if status == errSecDuplicateItem {
            
            status = SecItemDelete(query as CFDictionary)
            status = SecItemAdd(query as CFDictionary, &raw)
        }
        
        guard status == errSecSuccess else {
            
            throw SecureEnclaveHelperError(message: "Could not save keypair", osStatus: status)
        }
    }
    
    private var attrKeyTypeEllipticCurve: String {
        
        if #available(iOS 10.0, *) {
            
            return kSecAttrKeyTypeECSECPrimeRandom as String
        }
        else {
            
            return kSecAttrKeyTypeEC as String
        }
    }
    
    private func getSecKeyWithQuery(_ query: [String: Any]) throws -> CFTypeRef {
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            throw SecureEnclaveHelperError(message: "Could not get key for query: \(query)", osStatus: status)
        }
        return result!
    }
}
