import UIKit

class YD_Home_VC: UIViewController {

    @IBOutlet var  buttons: [UIButton] = []
    private let feedback_string = "Debugger attached ="
    
    @IBAction func ptrace_asm_button(_ sender: Any) {
        YDDebuggerPtrace.invokePtrace()
    }
    
    @IBAction func exception_port_button(_ sender: Any) {
        print("about to check Exception Ports")
        let result = debugger_exception_ports()
        present_alert_controller(user_message: feedback_string + " \(result)")
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
        buttons.forEach {
            $0.YDButtonStyle(ydColor: UIColor.blue)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        super.tabBarController?.title = "Debugger detections"
    }
    
    func present_alert_controller(user_message: String) {
        let time = YD_Time_Helper(raw_date: Date())
        let alert = YD_Alert_Helper(body_message: user_message + "\n\n\(time.readable_date)")
        self.present(alert.alert_controller, animated: true, completion: nil)
    }
}
