//
//  AccessToken.swift
//  Emissary
//
//  Created by Jordan Kay on 12/3/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

public protocol AccessToken: Codable, PathAccessible {
    var accessToken: String { get }
    var refreshToken: String { get }
    var creationDate: Date { get }
    var expirationDate: Date { get }
    
    init(accessToken: String, refreshToken: String, creationDate: Date, expirationDate: Date)
}

public extension AccessToken {
    // MARK: Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accessToken = try container.decode(String.self, forKey: .accessToken)
        let refreshToken = try container.decode(String.self, forKey: .refreshToken)
        let expirationTime = try container.decode(Double.self, forKey: .expirationTime)
        let creationDate = Date()
        let expirationDate = try container.decodeIfPresent(Date.self, forKey: .expirationDate) ?? .init(timeInterval: expirationTime, since: creationDate)
        self.init(accessToken: accessToken, refreshToken: refreshToken, creationDate: creationDate, expirationDate: expirationDate)
    }
    
    // MARK: Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(expirationDate, forKey: .expirationDate)
    }
}

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
    
    static func retrieveFromKeychain() -> Self? {
        let keychain = Keychain()
        guard let data = keychain[data: .accessToken] else { return nil }
        
        let token = try! JSONDecoder().decode(Self.self, from: data)
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

private enum CodingKeys: String, CodingKey {
    case accessToken
    case refreshToken
    case creationDate
    case expirationTime = "expiresIn"
    case expirationDate
}

private extension String {
    static let accessToken = "accessToken"
}
