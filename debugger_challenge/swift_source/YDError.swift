enum YDNetworkError: Error {
        case dataError
        case responseError
        case urlNotSupported
        case timeOut
        case hostIssue
        case noInternet
        case serverOffline
        case certChainIssue
        case cancelledURLSession
        case certIssue
        case badServerResponse
        case unknownError(Int)
}

extension YDNetworkError {
    init?(receivedError: Error)  {
        switch receivedError._code {
        case NSURLErrorCannotFindHost:
            self = .hostIssue
        case NSURLErrorUnsupportedURL:
            self = .urlNotSupported
        case NSURLErrorCancelled:
            self = .cancelledURLSession
        case NSURLErrorCannotConnectToHost:
            self = .timeOut
        case NSURLErrorTimedOut:
            self = .timeOut
        case NSURLErrorNotConnectedToInternet:
            self = .noInternet
        case NSURLErrorServerCertificateUntrusted:
            self = .certIssue
        case NSURLErrorSecureConnectionFailed:
            self = .certChainIssue
        default:
            self = .unknownError(receivedError._code)
        }
    }
}
extension YDNetworkError: LocalizedError {

    var errorDescription: String? {
        switch self {
            case .hostIssue:
                return "Cannot find host"
            case .urlNotSupported:
                return "URL not supported error"
            case .timeOut:
                return "Timeout, no response received"
            case .certIssue:
                return "cert issue"
            case .cancelledURLSession:
                return "Did you cancel the URLSession request?"
            case .badServerResponse:
                return "bad server response"
            case .certChainIssue:
                return "check Root and Int Certificates are trusted"
            case .unknownError:
                return "non-mapped error.  \(self)"
            default:
                return "generic error desc"
        }
    }
}
