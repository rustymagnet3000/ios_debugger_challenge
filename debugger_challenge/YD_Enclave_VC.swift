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
    let ydHammer = YDHammertime(publicLabel: "com.hammer.publicKey", privateLabel: "com.hammer.privateKey", operationPrompt: "Authenticate to continue")
    

    @IBAction func sign_btn(_ sender: Any) {
        signatureLabel.text = "sign time"
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
            let enclaveData = try ydHammer.getPublicKey()
            print("Secure Enclave Reference: \(enclaveData.ref.underlying.hashValue)")
            
            if #available(iOS 10.3, *) {
                cipherText = try ydHammer.encrypt(ptBytes!, publicKey: enclaveData.ref)
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
            print(keypairResult.public.underlying)
            print("Secure Enclave Reference: \(enclaveData.ref.underlying.hashValue)")
            pubKeyLabel.text = "Public Key: " + enclaveData.hex
        }
        catch {
            pubKeyLabel.text = "error in key generation or get Pub Key"
        }
    }
}
