//
//  File.swift
//  
//
//  Created by Nicholas Mata on 5/20/20.
//

import Foundation

public protocol OAuthStore {
    var accessToken: OAuthToken? {get set}
    var refreshToken: OAuthToken? {get set}
}
