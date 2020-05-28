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

    public init(sessionConfiguration: URLSessionConfiguration?) {
        self.sessionConfiguration = sessionConfiguration
    }
}

public typealias Modifier = Header

public class Api {
    public var connection: Connection
    var modifiers: [Modifier]

    public init(modifiers: [Modifier] = [], options: ApiOptions?) {
        connection = Connection(sessionConfig: options?.sessionConfiguration)
        self.modifiers = modifiers
    }

    public func retrieve<T: Decodable>(request: Requestable, completion: @escaping (Result<T, Error>) -> Void) throws {
        let request = try request.build()
        let finalRequest = modifiers.reduce(request) { (request: URLRequest, modifier: Modifier) -> URLRequest in
            (try? modifier.modify(request: request)) ?? request
        }
        connection.send(request: finalRequest, completion: completion)
    }
}
#endif
