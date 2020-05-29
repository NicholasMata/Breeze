#if canImport(UIKit)
import UIKit

enum ConnectionError: LocalizedError {
    case impossible
    case failureStatusCode(Int, Data?)
}

public class Connection {
    public var urlSession: URLSession
    public var queue: DispatchQueue
    
    public convenience init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval(30)
        config.timeoutIntervalForResource = TimeInterval(30)
        self.init(sessionConfig: config)
    }
    
    public init(sessionConfig: URLSessionConfiguration? = nil,
                delegate: URLSessionDelegate? = nil,
                delegateQueue: OperationQueue? = nil) {
        let defaultConfig = URLSessionConfiguration.default
        defaultConfig.timeoutIntervalForRequest = TimeInterval(30)
        defaultConfig.timeoutIntervalForResource = TimeInterval(30)
        self.queue = DispatchQueue(label: "com.breeze.api", qos: .utility)
        self.urlSession = URLSession(configuration: sessionConfig ?? defaultConfig,
                                     delegate: delegate,
                                     delegateQueue: delegateQueue ?? OperationQueue.main)
    }
    
    public typealias RawResponseResult = Result<(data: Data, response: URLResponse), Error>
    public typealias ResponseResult<T> = Result<T, Error>
    
    public func send<T: Decodable>(request: URLRequest,
                                   completion: @escaping (ResponseResult<T>) -> Void,
                                   decoder: JSONDecoder = JSONDecoder()) {
        self.send(request: request) { rawResult in
            var result: ResponseResult<T>
            switch rawResult {
            case .success(let res):
                do {
                    let json = try decoder.decode(T.self, from: res.data)
                    result = .success(json)
                } catch let err {
                    result = .failure(err)
                }
            case .failure(let err):
                result = .failure(err)
            }
            completion(result)
        }
    }
    
    public func send(request: URLRequest, completion: @escaping (RawResponseResult) -> Void) {
        self.urlSession.dataTask(with: request) { data, response, err in
            var result: RawResponseResult
            if let err = err {
                result = .failure(err)
            } else if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode > 299 {
                result = .failure(ConnectionError.failureStatusCode(response.statusCode, data))
            } else if let data = data, let response = response {
                result = .success((data, response))
            } else {
                result = .failure(ConnectionError.impossible)
            }
            completion(result)
        }.resume()
    }
}

// public class Breeze {
//    private var semaphore = DispatchSemaphore(value: 0)
//    private var urlSession: URLSession
//    private var queue: DispatchQueue
//
//    public convenience init(url: String) {
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = TimeInterval(30)
//        config.timeoutIntervalForResource = TimeInterval(30)
//        self.init(clientId: clientId, clientSecret: clientSecret, sessionConfig: config, store: store)
//    }
//
//    public init(sessionConfig: URLSessionConfiguration,
//                store: OAuthStore?) {
//        self.clientId = clientId
//        self.clientSecret = clientSecret
//        self.queue = DispatchQueue(label: "com.breeze.api", qos: .utility)
//        self.urlSession = URLSession(configuration: sessionConfig)
//        self.store = store
//        self.accessToken = store?.accessToken ?? OAuthToken()
//        self.refreshToken = store?.refreshToken ?? OAuthToken()
//    }
//
//    public send<T: Decodable>(request: Request, completion: @escaping(Result<T, Error>)) {
//
//        return self.send(request: <#T##URLRequest#>, completion: <#T##(Result<Decodable, Error>)#>)
//    }
//
//    internal send<T: Decodable>(request: URLRequest, completion: @escaping(Result<T, Error>)) {
//        self.urlSession.dataTask(with: request) { (data, response, err) in
//            completionHandler?(data, response, err)
//        }.resume()
//    }
// }
//
// public class Api {
//    public var clientId: String
//    public var clientSecret: String
////    public var delegate: PhilinqDelegate?
//    public var store: OAuthStore?
//    /// A token used for authentication.
//    public private(set) var accessToken: OAuthToken {
//        didSet {
//            store?.accessToken = accessToken
//        }
//    }
//    public private(set) var refreshToken: OAuthToken {
//        didSet {
//            store?.refreshToken = refreshToken
//        }
//    }
//    private var semaphore = DispatchSemaphore(value: 0)
//    private var urlSession: URLSession
//    private var queue: DispatchQueue
//
//    public convenience init(clientId: String, clientSecret: String, store: OAuthStore? = nil, url: String) {
//        let config = URLSessionConfiguration.default
//        config.timeoutIntervalForRequest = TimeInterval(30)
//        config.timeoutIntervalForResource = TimeInterval(30)
//        self.init(clientId: clientId, clientSecret: clientSecret, sessionConfig: config, store: store)
//    }
//
//    public init(clientId: String, clientSecret: String, sessionConfig: URLSessionConfiguration,
//                store: OAuthStore?) {
//        self.clientId = clientId
//        self.clientSecret = clientSecret
//        self.queue = DispatchQueue(label: "com.breeze.api", qos: .utility)
//        self.urlSession = URLSession(configuration: sessionConfig)
//        self.store = store
//        self.accessToken = store?.accessToken ?? OAuthToken()
//        self.refreshToken = store?.refreshToken ?? OAuthToken()
//    }
//
//    internal func makeDataRequest(url: String,
//                              method: HTTPMethod,
//                              body: Data? = nil,
//                              contentType: PLContentType = .json,
//                              completionHandler: ((Data?, URLResponse?, Error?)->())? = nil) {
//        guard let requestUrl = URL(string: "\(self.env.apiUrl())/\(url)") else {
//            completionHandler?(nil, nil, ApiRequestError.invalidUrl(url))
//            return
//        }
//        var request = URLRequest(url: requestUrl)
//        request.httpMethod = method.rawValue
//        request.httpBody = body
//        request.addValue(String(describing: contentType), forHTTPHeaderField: "Content-Type")
//
//        if let accessToken = self.accessToken.value {
//            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        }
//
//        self.urlSession.dataTask(with: request) { (data, response, err) in
//            completionHandler?(data, response, err)
//        }.resume()
//    }
//
//
//    internal func makeRequest<T: Decodable>(url: String,
//                                            method: HTTPMethod,
//                                            body: Data? = nil,
//                                            contentType: PLContentType = .json,
//                                            decoder: JSONDecoder = JSONDecoder(),
//                                            completionHandler: ((T?, Error?)->())? = nil) {
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
//        decoder.dateDecodingStrategy = .formatted(dateFormatter)
//
//        self.makeDataRequest(url: url, method: method, body: body, contentType: contentType) { (data, response, err) in
//            guard let data = data, let response = response as? HTTPURLResponse, err == nil else {
//                completionHandler?(nil, err)
//                return
//            }
//            do {
//                switch response.statusCode  {
//                case 200..<300:
//                    completionHandler?(try decoder.decode(T.self, from: data), nil)
//                default:
//                    let snakeDecoder = JSONDecoder()
//                    snakeDecoder.keyDecodingStrategy = .convertFromSnakeCase
//                    let errorResponse = try? snakeDecoder.decode(ErrorResponse.self, from: data)
//                    completionHandler?(nil, ApiError.failed(errorResponse?.error, errorResponse?.errorDescription, response.statusCode))
//                }
//            } catch let err {
//                completionHandler?(nil, err)
//            }
//        }
//    }
// }
#endif
