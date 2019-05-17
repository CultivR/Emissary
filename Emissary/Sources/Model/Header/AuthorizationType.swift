//
//  Authorization.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public enum AuthorizationType {
    case basic(username: String, password: String)
    case bearer(AccessToken)
    case jwt(token: String)
}

extension AuthorizationType: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .basic(username, password):
            let data = Data("\(username):\(password)".utf8)
            let string = data.base64EncodedString()
            return "Basic \(string)"
        case let .bearer(accessToken):
            return "Bearer \(accessToken.accessToken)"
        case let .jwt(token):
            return "JWT \(token)"
        }
    }
}
