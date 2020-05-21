//
//  File.swift
//  
//
//  Created by Nicholas Mata on 5/20/20.
//

import Foundation

public struct JsonRequest<T: Encodable>: Requestable, Header {
    public var url: String
    public var body: T?
    public var method: RequestMethod
    public var headers: [String: String]?
    
    public init(url: String,
                method: RequestMethod = .get,
                body: T? = nil,
                headers: [String:String]? = nil) {
        self.url = url
        self.method = method
        self.body = body
        self.headers = headers
    }
    
    public func build() throws -> URLRequest {
        guard let url = URL(string: self.url) else {
            throw RequestError.invalidUrl(self.url)
        }
        return try modify(request: URLRequest(url: url))
    }
    
    public func modify(request: URLRequest) throws -> URLRequest {
        var request = request
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = self.headers
        if let body = body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }
        return request
    }
}
