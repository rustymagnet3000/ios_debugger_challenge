import UIKit

class YD_Enclave_VC: UIViewController {
    
    @IBOutlet weak var pubKeyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func secure_enclave_btn(_ sender: Any) {

        let ydHammer = YDHammertime(publicLabel: "no.agens.demo.publicKey", privateLabel: "no.agens.demo.privateKey", operationPrompt: "Authenticate to continue")
        do{
            let accessControl = try ydHammer.accessControl(with: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
            let keypairResult = try ydHammer.generateKeyPair(accessControl: accessControl)
            try ydHammer.forceSavePublicKey(keypairResult.public)
            let enclaveData = try ydHammer.getPublicKey()
            print(enclaveData.ref.underlying.hashValue)
            pubKeyLabel.text = "Public Key: " + enclaveData.hex

        }
        catch {
            pubKeyLabel.text = "error in key generation or get Pub Key"
        }
    }
}
