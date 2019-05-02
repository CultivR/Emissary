//
//  AuthorizationResponse.swift
//  Model
//
//  Created by Jordan Kay on 5/2/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public enum AuthorizationResponseType: String {
    case code
}

extension AuthorizationResponseType: ParameterValue {}
