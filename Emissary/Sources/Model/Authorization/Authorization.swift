//
//  Authorization.swift
//  Model
//
//  Created by Jordan Kay on 5/2/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol Authorization: PathAccessible {}

extension Authorization {
    static func parameters(clientID: String, redirectURI: String) -> [AuthorizationParameter] {
        return [
            [.clientID: clientID],
            [.responseType: AuthorizationResponseType.code],
            [.redirectURI: redirectURI]
        ]
    }
}
