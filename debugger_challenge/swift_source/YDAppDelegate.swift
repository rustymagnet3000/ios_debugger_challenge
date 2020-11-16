import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /*** Mark: change navigation header colour ***/
        UINavigationBar.appearance().barTintColor = UIColor.green
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification,
                object: nil,
                queue: mainQueue) { notification in
                    print("[!]detected screenshot")
            YDRandomVC.screenshotCount += 1
            }

        return true
    }
}
