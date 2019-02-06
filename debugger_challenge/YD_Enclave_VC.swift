import UIKit

class YD_Enclave_VC: UIViewController {
    
    @IBOutlet weak var signatureVerifyLbl: UILabel!
    @IBOutlet weak var signatureLabel: UILabel!
    @IBOutlet weak var plaintextResult: UILabel!
    @IBOutlet weak var ctLbl: UILabel!
    var cipherText: Data = "default ciphertext".data(using: .utf8)!
    @IBOutlet weak var pubKeyLabel: UILabel!
    @IBOutlet weak var encrypt_btn_outlet: UIButton!
    @IBOutlet weak var ptLbl: UILabel!
    
    let ptBytes: Data? = "The quick brown fox".data(using: .utf8)
    let ydHammer = YDHammertime(publicLabel: "com.hammer.publicKey", privateLabel: "com.hammer.privateKey", operationPrompt: "Please authenticate")

    @IBAction func sign_btn(_ sender: Any) {
        do {
            let pkEnclaveKeyRef = try ydHammer.getPrivateKey()
            print("Enclave Ref: \(pkEnclaveKeyRef.underlying.hashValue)")
            
            if #available(iOS 10.3, *) {
                let signedPt = try ydHammer.sign(ptBytes!, privateKey: pkEnclaveKeyRef)
                print("Signature: \(signedPt.base64EncodedString())")
                signatureLabel.text = "Signature: " + signedPt.base64EncodedString()
            } else {
                signatureLabel.text = "pre iOS 10.3"
            }
        }
        catch {
            signatureLabel.text = "error in sign step"
        }
    }
    
    @IBAction func verify_btn(_ sender: Any) {
         signatureVerifyLbl.text = "verify time"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ptLbl.text = String(data: ptBytes!, encoding: .utf8)
    }

    @IBAction func decrypt_btn(_ sender: Any) {
        do {
            let pkEnclaveData = try ydHammer.getPrivateKey()
            print("Secure Enclave Reference: \(pkEnclaveData.underlying.hashValue)")
            
            if #available(iOS 10.3, *) {
                let decPlaintext = try ydHammer.decrypt(cipherText, privateKey: pkEnclaveData)
                print("Plaintext: \(decPlaintext.base64EncodedString())")
                plaintextResult.text = String(data: decPlaintext, encoding: .utf8)
            } else {
                plaintextResult.text = "pre iOS 10.3"
            }
        }
        catch {
            plaintextResult.text = "error in decrypt"
        }
    }
    
    @IBAction func encrypt_btn(_ sender: Any) {
        do {
            let enclaveKeyData = try ydHammer.getPublicKey()

            if #available(iOS 10.3, *) {
                cipherText = try ydHammer.encrypt(ptBytes!, publicKey: enclaveKeyData.ref)
                ctLbl.text = "Padded Cipertext: " + cipherText.base64EncodedString()
            } else {
                ctLbl.text = "pre iOS 10.3"
            }
        }
        catch {
            ctLbl.text = "error in encrypt"
        }
    }
    
    @IBAction func generate_keypair_btn(_ sender: Any) {
        do{
            let accessControl = try ydHammer.accessControl(with: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
            let keypairResult = try ydHammer.generateKeyPair(accessControl: accessControl)
            try ydHammer.forceSavePublicKey(keypairResult.public)
            let enclaveData = try ydHammer.getPublicKey()
            pubKeyLabel.text = "Public Key: " + enclaveData.hex
        }
        catch {
            pubKeyLabel.text = "error in key generation or get Pub Key"
        }
    }
}
