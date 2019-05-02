//
//  Authorization.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public enum AuthorizationType {
    case basic(username: String, password: String)
    case bearer(credentials: String)
    case jwt(token: String)
}

extension AuthorizationType: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .basic(username, password):
            let data = "\(username):\(password)".data(using: .utf8)!
            let string = data.base64EncodedString()
            return "Basic \(string)"
        case let .bearer(credentials):
            return "Bearer \(credentials)"
        case let .jwt(token):
            return "JWT \(token)"
        }
    }
}
