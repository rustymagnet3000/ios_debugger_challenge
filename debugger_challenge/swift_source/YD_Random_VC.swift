import UIKit

class YD_Random_VC: UIViewController {

    @IBOutlet var  buttons: [UIButton] = []
       
    @IBAction func crypto_button(_ sender: Any) {
        self.YDAlertController(user_message: "about to call common crypto API")
        YD_Crypto_Helper.funky()
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
