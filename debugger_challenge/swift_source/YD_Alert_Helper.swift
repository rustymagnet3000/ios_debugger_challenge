import UIKit

class YD_Alert_Helper {
    var alert_controller: UIAlertController
    var title_message: String
    var body_message: String

    convenience init(body_message: String) {
        let generic_title = "Result"
        self.init(title: generic_title, message: body_message)
    }
    
    init(title: String, message: String) {
        self.alert_controller = UIAlertController(title: title, message:
        message, preferredStyle: UIAlertController.Style.alert)
        self.alert_controller.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel,handler: nil))
        self.title_message = title
        self.body_message = message
    }
}

extension UIViewController {
    func YDAlertController(user_message: String) {
        let time = YD_Time_Helper(raw_date: Date())
        let alert = YD_Alert_Helper(body_message: user_message + " 🐝\n\n\(time.readable_date)")
        self.present(alert.alert_controller, animated: true, completion: nil)
    }
    
    func YDAlertController(title: String, message: String) {
        let alert = YD_Alert_Helper(title: title, message: message)
        self.present(alert.alert_controller, animated: true, completion: nil)
    }
}
