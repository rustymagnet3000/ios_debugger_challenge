import UIKit

class YDRandomVC: UIViewController {

    static var screenshotCount = 0
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
    
    @IBAction func get_some_bytes(_ sender: Any) {
        self.YDAlertController(user_message: "BYTES")
    }
    
    @IBAction func jailbreak_check(_ sender: Any) {
        let result = YDFileChecker.checkFileExists()
            self.YDAlertController(user_message: "Jailbroken: \(result)")
    }
    
    @IBAction func file_exists_check(_ sender: Any) {
        let result = YDFileChecker.checkFileExists()
            self.YDAlertController(user_message: "Checking if info.plist exists: \(result)")
    }
    
    @IBAction func screenshot_check(_ sender: Any) {
        self.YDAlertController(user_message: "Screenshot counter: \(YDRandomVC.screenshotCount)")
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
