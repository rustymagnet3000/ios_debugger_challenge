import UIKit

class YD_Home_VC: UIViewController {

    @IBOutlet var  buttons: [UIButton] = []
    fileprivate let feedback_string = "Debugger attached ="
    fileprivate let tab_title = "Debugger detections"

    @IBAction func ppid_button(_ sender: Any) {
        let result = YDDebuggerPtrace.checkParent()
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func ptrace_asm_button(_ sender: Any) {
        let result = YDDebuggerPtrace.setPtraceWithASM()
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func exception_port_button(_ sender: Any) {
        let result = debugger_exception_ports()
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func ptrace_chk_btn(_ sender: Any) {
        let result = YDDebuggerPtrace.setPtraceWithSymbol()
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func debug_chk_btn(_ sender: UIButton) {
        let result = debugger_sysctl()
        self.YDAlertController(user_message: feedback_string + " \(result)")
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
}
