//
//  GrantType.swift
//  Model
//
//  Created by Jordan Kay on 5/1/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public enum AuthorizationGrantType: String {
    case authorizationCode = "authorization_code"
    case refreshToken = "refresh_token"
}

extension AuthorizationGrantType: ParameterValue {}
