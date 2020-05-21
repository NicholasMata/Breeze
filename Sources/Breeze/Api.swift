//
//  File.swift
//  
//
//  Created by Nicholas Mata on 5/20/20.
//
#if canImport(UIKit)
import UIKit

public struct ApiOptions {
    var sessionConfiguration: URLSessionConfiguration?
}

public typealias Modifier = Header

public class Api {
    var connection: Connection
    var modifiers: [Modifier]
    
    public init(modifiers: [Modifier] = [], options: ApiOptions?) {
        connection = Connection(sessionConfig: options?.sessionConfiguration)
        self.modifiers = modifiers
    }
    
//    func apply(modifier: Modifier, to request: URLRequest, completion: @escaping(URLRequest) -> Void) {
//        switch modifier {
//        case let modifier as Header:
//            completion(modifier.modify(request: request))
//            break
//        case let modifier as AsyncHeader:
//            modifier.modify(request: request, completion: completion)
//            break
//        }
//    }
    
//    func modify(request: URLRequest, completion: @escaping(URLRequest) -> Void) {
//        self.
//    }
    
    public func retrieve<T: Decodable>(request: Requestable, completion: @escaping(Result<T, Error>) -> Void) throws  {
        let request = try request.build()
        let finalRequest = self.modifiers.reduce(request, { (request: URLRequest, modifier: Modifier) -> URLRequest in
            return (try? modifier.modify(request: request)) ?? request
        })
        connection.send(request: finalRequest, completion: completion)
    }
}
#endif
