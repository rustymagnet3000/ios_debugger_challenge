import Foundation

class YDURLSession: URLSession, URLSessionDelegate {
    
    enum FetchResult {
        case Success
        case Data
        case Error(Error)
    }

    var dataTask: URLSessionDataTask?
    var response: HTTPURLResponse?

    
    func fetchWithCompletionHandler(url: URL, completionHandler: @escaping (FetchResult)-> (Void)) {
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        dataTask = session.dataTask(with: url) { [weak self] data, response, error in
            defer {
              self?.dataTask = nil
            }
            
            var result: FetchResult = .Success
             
            if let e = error {
                result = .Error(e)
            }
            else if data == nil {
                result = .Data
            }
            if let response = response as? HTTPURLResponse {
                self?.response = response
            }
            
          DispatchQueue.main.async {
            completionHandler(result)
          }
        }

        dataTask?.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        print("🕵🏼‍♂️ challanged by: \(challenge.protectionSpace.host)")

        guard let trust: SecTrust = challenge.protectionSpace.serverTrust else {
            return
        }
        
        var secResult = SecTrustResultType.invalid
        SecTrustEvaluate(trust, &secResult)
        switch secResult {
            case .proceed:
                print("🕵🏼‍♂️ SecTrustEvaluate ✅")
            case .recoverableTrustFailure:
                print("🕵🏼‍♂️ SecTrustEvaluate ❌ check Root CA and Int CA trusted on IOS device")
            default:
                print("🕵🏼‍♂️ SecTrustEvaluate ❌ default error")
        }

        completionHandler(.performDefaultHandling, nil)
    }
}

