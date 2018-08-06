import Foundation

class YD_Crypto_Helper {

    static func funky() -> Void {
        // Encrypt
        let myString = "Ewoks don't wear pyjamas."
        let myData = myString.data(using: String.Encoding.utf8)! as Data  // note, not using NSData
        print("Input: \t\t\t\t" + myData.hexDescription)
        let password = "AAAAAAAA"
        let ciphertext = RNCryptor.encrypt(data: myData, withPassword: password)
        
        // Decrypt
        do {
            let decryptedData = try RNCryptor.decrypt(data: ciphertext, withPassword: password)
            print("Output: \t\t\t\t" + decryptedData.hexDescription)
            if let result = String(data: decryptedData, encoding: .utf8){
                print("plaintext result: \t\t" + result)
            }
            
        } catch {
            print(error)
        }
    }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
