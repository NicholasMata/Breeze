//
//  File.swift
//  
//
//  Created by Nicholas Mata on 5/20/20.
//

import Foundation

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol Requestable {
    func build() throws -> URLRequest
}

public protocol AsyncRequestable {
    func build(completion: @escaping(URLRequest) -> Void) throws -> Void
}

public protocol Header {
    func modify(request: URLRequest) throws  -> URLRequest
}

public protocol AsyncHeader {
    func modify(request: URLRequest, completion: (URLRequest) -> Void) throws  -> Void
}

public enum RequestError: LocalizedError {
    case invalidUrl(String)
    /// A description of the server error that occurred.
    public var errorDescription: String? {
        switch self {
        case .invalidUrl(let url):
            return "Invalid Url: \(url)"
        }
    }
}

public struct Request: Requestable, Header {
    public var url: String
    public var body: Data?
    public var method: RequestMethod
    public var headers: [String: String]?
    
    public init(url: String,
                method: RequestMethod = .get,
                body: Data? = nil,
                headers: [String: String]? = nil) {
        self.url = url
        self.method = method
        self.body = body
        self.headers = headers
    }
    
    public func build() throws -> URLRequest {
        guard let url = URL(string: self.url) else {
            throw RequestError.invalidUrl(self.url)
        }
        let request = URLRequest(url: url)
        return try self.modify(request: request)
    }
    
    public func modify(request: URLRequest) throws -> URLRequest {
        var request = request
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = self.headers
        request.httpBody = self.body
        return request
    }
}
