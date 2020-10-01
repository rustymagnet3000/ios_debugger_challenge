import UIKit

class YD_URLSession_VC: UIViewController {

    @IBOutlet weak var btn_outlet: UIButton!
    fileprivate let urlstr = "https://www.httpbin.org/get"
    
    @IBAction func send_request_btn(_ sender: Any) {
        nsUrlSessionTapped()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btnClr = UIColor(red: 1, green: 165/255, blue: 0, alpha: 1)
        btn_outlet.YDButtonStyle(ydColor: btnClr)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        super.tabBarController?.title = "Try and bypass URLAuthenticationChallenge"
    }
    
    func nsUrlSessionTapped() {
        let a = YDURLSession()
        guard let url = URL(string: urlstr) else {
            return
        }
        
        a.fetchWithCompletionHandler(url: url){ (result) in
            switch result {
                case .Success:
                    self.YDAlertController(user_message: "iOS Trust Store verified ✅")
                case .Error(let error):
                    let z = YDNetworkError(receivedError: error)
                    self.YDAlertController(title: "Error", message: z?.localizedDescription ?? "not mapped")
                default:
                    self.YDAlertController(user_message: "\(result).")
            }
        }
    }
}
