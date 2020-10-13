import Foundation

class YDCryptoHelper {

    enum AESError: Error {
        case KeyError((String, Int))
        case IVError((String, Int))
        case CryptorError((String, Int))
    }
    
    // The iv is prefixed to the encrypted data
    func aesCBCEncrypt(data:Data, keyData:Data) throws -> Data {
        let keyLength = keyData.count
        let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
        if (validKeyLengths.contains(keyLength) == false) {
            throw AESError.KeyError(("Invalid key length", keyLength))
        }
        
        let ivSize = kCCBlockSizeAES128;
        let cryptLength = size_t(ivSize + data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)
        
        let status = cryptData.withUnsafeMutableBytes {ivBytes in
            SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, ivBytes)
        }
        if (status != 0) {
            throw AESError.IVError(("IV generation failed", Int(status)))
        }
        
        var numBytesEncrypted :size_t = 0
        let options   = CCOptions(kCCOptionPKCS7Padding)
        
        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            options,
                            keyBytes, keyLength,
                            cryptBytes,
                            dataBytes, data.count,
                            cryptBytes+kCCBlockSizeAES128, cryptLength,
                            &numBytesEncrypted)
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.count = numBytesEncrypted + ivSize
        }
        else {
            throw AESError.CryptorError(("Encryption failed", Int(cryptStatus)))
        }
        
        return cryptData;
    }
    
    // The iv is prefixed to the encrypted data
    func aesCBCDecrypt(data:Data, keyData:Data) throws -> Data? {
        let keyLength = keyData.count
        let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]
        if (validKeyLengths.contains(keyLength) == false) {
            throw AESError.KeyError(("Invalid key length", keyLength))
        }
        
        let ivSize = kCCBlockSizeAES128;
        let clearLength = size_t(data.count - ivSize)
        var clearData = Data(count:clearLength)
        
        var numBytesDecrypted :size_t = 0
        let options   = CCOptions(kCCOptionPKCS7Padding)
        
        let cryptStatus = clearData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            options,
                            keyBytes, keyLength,
                            dataBytes,
                            dataBytes+kCCBlockSizeAES128, clearLength,
                            cryptBytes, clearLength,
                            &numBytesDecrypted)
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            clearData.count = numBytesDecrypted
        }
        else {
            throw AESError.CryptorError(("Decryption failed", Int(cryptStatus)))
        }
        
        return clearData;
    }

    
    
    static func funky() -> Void {

        let clearData = "clearData0123456".data(using:String.Encoding.utf8)!
        let keyData   = "AAAAAAAAAAAAAAAA".data(using:String.Encoding.utf8)!
        print("clearData:   \(clearData as NSData)")
        print("keyData:     \(keyData as NSData)")
        let a = YDCryptoHelper()
        var cryptData :Data?
        do {
            cryptData = try a.aesCBCEncrypt(data:clearData, keyData:keyData)
            print("cryptData:   \(cryptData! as NSData)")
        }
        catch (let status) {
            print("Error aesCBCEncrypt: \(status)")
        }
        
        let _ :Data?
        do {
            let decryptData = try a.aesCBCDecrypt(data:cryptData!, keyData:keyData)
            print("decryptData: \(decryptData! as NSData)")
        }
        catch (let status) {
            print("Error aesCBCDecrypt: \(status)")
        }
        
//        // Encrypt
//        let myString = "Ewoks don't wear pyjamas."
//        let myData = myString.data(using: String.Encoding.utf8)! as Data  // note, not using NSData
//        print("Input: \t\t\t\t" + myData.hexDescription)
//        let password = "AAAAAAAA"
//
//        let string1 = String(data: myData, encoding: String.Encoding.utf8) ?? "Data could not be printed"
//        print("[+]string encoded Data: " + string1)
//        let ciphertext = RNCryptor.encrypt(data: myData, withPassword: password)
//
//        // Decrypt
//        do {
//            let decryptedData = try RNCryptor.decrypt(data: ciphertext, withPassword: password)
//            print("Output: \t\t\t\t" + decryptedData.hexDescription)
//            if let result = String(data: decryptedData, encoding: .utf8){
//                print("plaintext result: \t\t" + result)
//            }
//
//        } catch {
//            print(error)
//        }
    }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
