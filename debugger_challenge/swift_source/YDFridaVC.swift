import UIKit

class YDFridaVC: UIViewController {

    @IBOutlet var  disabledbuttons: [UIButton] = []
    @IBOutlet var  buttons: [UIButton] = []
    fileprivate let feedback_string = "Frida detected ="
    fileprivate let tab_title = "Frida detections"
    fileprivate var child = YDSpinnerVC()
    
    @IBAction func frida_file_check(_ sender: Any) {
        let result = YDFridaDetection.checkIfFridaInstalled()
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    
    @IBAction func frida_port_check(_ sender: Any) {
        
        addSpinnerView()
        DispatchQueue.global(qos: .background).async {
            let result = YDFridaDetection.checkDefaultPort()
            DispatchQueue.main.async {
                self.child.willMove(toParent: nil)
                self.child.beginAppearanceTransition(false, animated: true)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
                self.YDAlertController(user_message: self.feedback_string + " \(result)")
            }
        }
    }
    
    @IBAction func frida_dylib_check(_ sender: Any) {
        let result = YDFridaDetection.checkLoadAddress()
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func frida_module_check(_ sender: Any) {
        let result = YDFridaDetection.checkModules()
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    @IBAction func frida_trace_check(_ sender: Any) {
        let result = false      //TODO: add correct tracing call
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttons.forEach { $0.YDButtonStyle(ydColor: UIColor.darkGray) }
        disabledbuttons.forEach {
            $0.isEnabled = false
            $0.alpha = 0.1;
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        super.tabBarController?.title = tab_title
    }
    
    func addSpinnerView() {
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}
