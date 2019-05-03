//
//  AccessToken.swift
//  Emissary
//
//  Created by Jordan Kay on 12/3/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

public struct AccessToken {
    let accessToken: String
    let refreshToken: String
    let creationDate: Date
    let expirationDate: Date
}

// MARK: -
extension AccessToken {
    var isExpired: Bool {
        let currentDate = Date()
        return currentDate > expirationDate
    }
    
    func storeInKeychain() {
        let keychain = Keychain()
        keychain[data: .accessToken] = try! JSONEncoder().encode(self)
    }
    
    static func removeFromKeychain() {
        let keychain = Keychain()
        keychain[.accessToken] = nil
    }
    
    static func retrieveFromKeychain() -> AccessToken? {
        let keychain = Keychain()
        guard let data = keychain[data: .accessToken] else { return nil }
        
        let token = try! JSONDecoder().decode(AccessToken.self, from: data)
        return token
    }
    
    static func parameters(clientID: String, authorizationCode: AuthorizationCode, redirectURI: String) -> [AuthorizationParameter] {
        return [
            [.clientID: clientID],
            [.code: authorizationCode],
            [.grantType: AuthorizationGrantType.authorizationCode],
            [.redirectURI: redirectURI]
        ]
    }
}

// MARK: -
extension AccessToken: Decodable {
    // MARK: Decodable
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessToken = try container.decode(String.self, forKey: .accessToken)
        let refreshToken = try container.decode(String.self, forKey: .refreshToken)
        
        let creationDate = Date()
        let expirationDate: Date
        if let expirationTime = try container.decodeIfPresent(Double.self, forKey: .expirationTime) {
            expirationDate = .init(timeInterval: expirationTime, since: creationDate)
        } else {
            expirationDate = try container.decode(Date.self, forKey: .expirationDate)
        }
        
        self.init(accessToken: accessToken, refreshToken: refreshToken, creationDate: creationDate, expirationDate: expirationDate)
    }
}

extension AccessToken: Encodable {
    // MARK: Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(expirationDate, forKey: .expirationDate)
    }
}

extension AccessToken: PathAccessible {
    public enum PathComponents: String, PathComponent {
        case token
    }
    
    // MARK: SubpathRepresentable
    public static var component: PathComponents {
        return .token
    }
}

// MARK: -
private extension AccessToken {
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case creationDate
        case expirationTime = "expiresIn"
        case expirationDate
    }
}

// MARK: -
private extension String {
    static let accessToken = "accessToken"
}
