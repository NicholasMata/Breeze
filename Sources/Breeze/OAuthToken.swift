//
//  File.swift
//  
//
//  Created by Nicholas Mata on 5/20/20.
//

import Foundation
#if canImport(UIKit)
import UIKit

public class OAuthToken: Codable {
    /// The token value.
    public var value: String?
    /// The expiration date of the token in UTC.
    public var expiration: Date = Date(timeIntervalSince1970: 0)
    
    public init(_ value: String? = nil, expiration: Date? = nil){
        self.value = value
        if let expiration = expiration {
            self.expiration = expiration
        }
    }
    
    /**
     Set expiration based on epoch/unix time.
     
     - Parameter expiration: When the token should expire in epoch/unix time.
     */
    public func expires(on expiration: Double?) {
        self.expiration = Date(timeIntervalSince1970: expiration ?? 0)
    }
    /**
     Set expiration based off seconds from current time.
     
     - Parameter expiresIn: In how many seconds should the token expire.
     */
    public func expires(in expiresIn: Double?) {
        self.expiration = Date().addingTimeInterval(expiresIn ?? 0)
    }
    
    /**
     Whether the token is expired.
     - Returns: A boolean indicating whether the token is expired
     */
    public func isExpired() -> Bool {
        return expiration <= Date()
    }
    
    /**
     Whether the token is valid. meaning is not expired and has a value.
     - Returns: A boolean indicating whether the token is valid.
     */
    public func isValid() -> Bool {
        return value != nil && !isExpired()
    }
}
#endif
