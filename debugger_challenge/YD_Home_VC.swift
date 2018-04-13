import UIKit

class YD_Home_VC: UIViewController {

    @IBAction func debug_chk_btn(_ sender: UIButton) {
        let result = debugger_check()
        present_alert_controller(user_message: "Debugged = \(result)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func present_alert_controller(user_message: String) {
        
        let time = YD_Time_Helper(raw_date: Date())
        let alert = YD_Alert_Helper(body_message: user_message + "\n\n\(time.readable_date)")
        self.present(alert.alert_controller, animated: true, completion: nil)
    }
}
