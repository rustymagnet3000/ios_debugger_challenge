import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /*** Mark: change navigation header colour ***/
        UINavigationBar.appearance().barTintColor = UIColor.green
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        if let cString = getenv("HOME") {
            let homeEnv = String(cString: cString)
            print("HOME env: \(homeEnv)")
        }
        
        return true
    }
}

