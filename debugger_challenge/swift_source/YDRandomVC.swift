import UIKit

class YDRandomVC: UIViewController {

    @IBOutlet var  buttons: [UIButton] = []
       
    @IBAction func crypto_button(_ sender: Any) {
        self.YDAlertController(user_message: "about to call common crypto API")
        YDCryptoHelper.funky()
    }
    
    @IBAction func random_string_btn(_ sender: Any) {
        let randomString = UUID()
        print(randomString.uuidString)
        self.YDAlertController(user_message: "Random string: \(randomString.uuidString)")
    }
    @IBAction func get_random_number_btn(_ sender: Any) {
        let answer = YDHelloClass().getRandomNumber()
        self.YDAlertController(user_message: "Random number: \(answer)")
    }
    
    @IBAction func file_check(_ sender: Any) {
        let result = YDFileChecker.checkFileExists()
            self.YDAlertController(user_message: "Checking for file: \(result)")
    }
    
    @IBAction func sandbox_check_fork(_ sender: Any) {
        let result = YDFileChecker.checkSandboxFork()
            self.YDAlertController(user_message: "Checking sandbox restrictions: \(result)")
    }
    
    @IBAction func sandbox_check_fopen(_ sender: Any) {
        let result = YDFileChecker.checkSandboxWrite()
            self.YDAlertController(user_message: "Checking sandbox restrictions: \(result)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons.forEach {
            $0.YDButtonStyle(ydColor: UIColor.lightGray)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        super.tabBarController?.title = "Press a button"
    }
}
