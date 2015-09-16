//
//  AuthToken.swift
//  Emissary
//
//  Created by Jordan Kay on 12/3/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

public protocol AuthToken: Codable {
    var userID: String { get }
    var accessToken: String { get }
    var refreshToken: String { get }
    var creationDate: Date { get }
    var expirationDate: Date { get }
}

public extension AuthToken {
    var isExpired: Bool {
        let currentDate = Date()
        return currentDate > expirationDate
    }

    func storeInKeychain() {
        let keychain = Keychain()
        keychain[data: .authToken] = try! JSONEncoder().encode(self)
    }
    
    static func removeFromKeychain() {
        let keychain = Keychain()
        keychain[.authToken] = nil
    }
    
    static func retrieveFromKeychain() -> AuthToken? {
        let keychain = Keychain()
        guard let data = keychain[data: .authToken] else { return nil }
        
        let token = try! JSONDecoder().decode(Self.self, from: data)
        return token
    }
}

private extension String {
    static let authToken = "authToken"
}
