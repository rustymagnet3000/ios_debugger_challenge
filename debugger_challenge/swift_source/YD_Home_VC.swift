import UIKit

class YD_Home_VC: UIViewController {

    @IBOutlet var  buttons: [UIButton] = []
    fileprivate let feedback_string = "Debugger attached ="
    fileprivate let tab_title = "Debugger detections"
    
    @IBAction func ptrace_asm_button(_ sender: Any) {
        let result = YDDebuggerPtrace.setPtraceWithASM()
        present_alert_controller(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func exception_port_button(_ sender: Any) {
        let result = debugger_exception_ports()
        present_alert_controller(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func ptrace_chk_btn(_ sender: Any) {
        let result = YDDebuggerPtrace.setPtraceWithSymbol()
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
        super.tabBarController?.title = tab_title
    }
    
    func present_alert_controller(user_message: String) {
        let time = YD_Time_Helper(raw_date: Date())
        let alert = YD_Alert_Helper(body_message: user_message + "\n\n\(time.readable_date)")
        self.present(alert.alert_controller, animated: true, completion: nil)
    }
}
