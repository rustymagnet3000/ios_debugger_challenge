import UIKit

class YD_Frida_VC: UIViewController {

    @IBOutlet var  buttons: [UIButton] = []
    fileprivate let feedback_string = "Frida detected ="
    fileprivate let tab_title = "Frida detections"
    
    @IBAction func frida_dylib_check(_ sender: Any) {
        let result = YDFridaDetection.checkLoadAddress()
        self.YDAlertController(user_message: feedback_string + " \(result)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons.forEach { $0.YDButtonStyle(ydColor: UIColor.red) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        super.tabBarController?.title = tab_title
    }
}
