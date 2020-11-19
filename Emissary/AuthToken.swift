//
//  AuthToken.swift
//  Emissary
//
//  Created by Jordan Kay on 12/3/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

import protocol Decodable.Decodable
import Decodable
import KeychainAccess

public struct AuthToken {
    public enum AuthTokenError: Error {
        case doesNotExist
        case expired(AuthToken)
    }
    
    public let accessToken: String
    public let refreshToken: String
    public let creationDate: Date
    public let expirationDate: Date?
    public let expirationDuration: TimeInterval?
    
    public init(accessToken: String, refreshToken: String? = nil, creationDate: Date? = nil, expirationDate: Date? = nil, expirationDuration: TimeInterval? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken ?? accessToken
        self.creationDate = creationDate ?? Date()
        self.expirationDate = expirationDate
        self.expirationDuration = expirationDuration
    }
}

public extension AuthToken {
    func storeInKeychain(withIdentifier identifier: String, encode: (AuthToken) -> [String: Any]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: encode(self))
        keychain[data: identifier] = data
    }
    
    static func removeFromKeychain(withIdentifier identifier: String) {
        let keychain = Keychain()
        keychain[identifier] = nil
    }
    
    static func retrieveFromKeychain(withIdentifier identifier: String, decode: (Any) throws -> AuthToken) throws -> AuthToken {
        guard let data = keychain[data: identifier] else {
            throw AuthTokenError.doesNotExist
        }
        
        let properties = NSKeyedUnarchiver.unarchiveObject(with: data)!
        let token = try decode(properties)
        guard !token.isExpired else {
            throw AuthTokenError.expired(token)
        }
        
        return token
    }
}

extension AuthToken: Decodable {
    public static func decode(_ json: Any) throws -> AuthToken {
        return try AuthToken(
            accessToken: json => "access_token",
            refreshToken: json => "refresh_token",
            creationDate: json => "created",
            expirationDate: json => "expires_in"
        )
    }
}

private extension AuthToken {
    var isExpired: Bool {
        let currentDate = Date()
        guard let expirationDate = expirationDate ?? (expirationDuration.map { creationDate.addingTimeInterval($0) }) else { return false }
        return currentDate > expirationDate
    }
}

private let keychain = Keychain()
