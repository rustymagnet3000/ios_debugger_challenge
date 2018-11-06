import UIKit

class YD_Home_VC: UIViewController {

    
    @IBAction func exception_port_button(_ sender: Any) {
        print("about to check Exception Ports")
        let result = debugger_exception_ports()
        present_alert_controller(user_message: feedback_string + " \(result)")
    }
    
    func secret_return_value(a: Int, b: Int) -> Int {
        return a * b
    }
    
    @IBAction func crypto_button(_ sender: Any) {
        print("about to call common crypto API")
        YD_Crypto_Helper.funky()
    }
    
    @IBAction func random_string_btn(_ sender: Any) {
        let randomString = NSUUID().uuidString
        present_alert_controller(user_message: "Random string: \(randomString)")
    }
    @IBAction func secret_btn(_ sender: Any) {
        
        let result = secret_return_value(a: 6, b: 7)
        present_alert_controller(user_message: "Secret: \(result)")
    }
    
    private let feedback_string = "Debugger attached ="
    
    @IBAction func crash_chk_btn(_ sender: Any) {
        var string: String! = "I'm a string!"
        print("Pre-crash: \(string.capitalized)")
        string = nil //Can be mutated to nil at runtime
        print("Crash time: \(string.capitalized)")  // Can't send messages to nil in Swift!
    }
    
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
        self.title = "Debugger Challenge"
    }

    func present_alert_controller(user_message: String) {
        let time = YD_Time_Helper(raw_date: Date())
        let alert = YD_Alert_Helper(body_message: user_message + "\n\n\(time.readable_date)")
        self.present(alert.alert_controller, animated: true, completion: nil)
    }
}
