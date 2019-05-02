//
//  AuthorizationParameter.swift
//  Model
//
//  Created by Jordan Kay on 5/2/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

typealias AuthorizationParameter = Parameter<AuthorizationParameterNames>

enum AuthorizationParameterNames: String, ParameterName {
    case clientID = "client_id"
    case responseType = "response_type"
    case grantType = "grant_type"
    case redirectURI = "redirect_uri"
    case code
    case refreshToken = "refresh_token"
}
