import UIKit

class YD_Frida_VC: UIViewController {

    @IBOutlet var  buttons: [UIButton] = []
    fileprivate let feedback_string = "Frida detected ="
    fileprivate let tab_title = "Frida detections"
    
    @IBAction func frida_port_check(_ sender: Any) {
    let result = YDFridaDetection.checkDefaultPort()
    self.YDAlertController(user_message: feedback_string + " \(result)")
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        super.tabBarController?.title = tab_title
    }
    
    func createSpinnerView() {
        let child = YDSpinnerVC()
        
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.beginAppearanceTransition(false, animated: true)
            child.view.removeFromSuperview()
            child.removeFromParent()

        }
    }
}