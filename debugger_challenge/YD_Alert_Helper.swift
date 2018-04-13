import UIKit

class YD_Alert_Helper {
    var alert_controller: UIAlertController
    var title_message: String
    var body_message: String
    
    convenience init(body_message: String) {
        let generic_title = "Result"
        let alert_template = UIAlertController(title: generic_title, message:
            body_message, preferredStyle: UIAlertControllerStyle.alert)
        alert_template.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel,handler: nil))
        
        self.init(alert_controller: alert_template, title_message: generic_title, body_message: body_message)
    }
    
    init(alert_controller: UIAlertController, title_message: String, body_message: String) {
        self.alert_controller = alert_controller
        self.title_message = title_message
        self.body_message = body_message
    }
}
