import UIKit

class YD_Home_VC: UIViewController {

    @IBOutlet var  buttons: [UIButton] = []
    
    @IBAction func exception_port_button(_ sender: Any) {
        print("about to check Exception Ports")
        let result = debugger_exception_ports()
        present_alert_controller(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func crypto_button(_ sender: Any) {
        print("about to call common crypto API")
        YD_Crypto_Helper.funky()
    }
    
    @IBAction func random_string_btn(_ sender: Any) {
        let randomString = UUID()
        print(randomString.uuidString)
        present_alert_controller(user_message: "Random string: \(randomString.uuidString)")
    }
    @IBAction func secret_btn(_ sender: Any) {
        let answer = YDHelloClass().getRandomNumber()
        present_alert_controller(user_message: "Random number: \(answer)")
    }
    
    private let feedback_string = "Debugger attached ="
    
    
    @IBAction func ptrace_chk_btn(_ sender: Any) {
        let result = debugger_ptrace()
        present_alert_controller(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func debug_chk_btn(_ sender: UIButton) {
        let result = debugger_sysctl()
        present_alert_controller(user_message: feedback_string + " \(result)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.tabBarController?.title = "Press a button"
        buttons.forEach {
            $0.YDButtonStyle(ydColor: UIColor.blue)
        }
    }

    func present_alert_controller(user_message: String) {
        let time = YD_Time_Helper(raw_date: Date())
        let alert = YD_Alert_Helper(body_message: user_message + "\n\n\(time.readable_date)")
        self.present(alert.alert_controller, animated: true, completion: nil)
    }
}
