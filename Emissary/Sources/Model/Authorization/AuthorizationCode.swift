//
//  AuthorizationCode.swift
//  Model
//
//  Created by Jordan Kay on 5/2/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

struct AuthorizationCode {
    let value: String
}

extension AuthorizationCode: ParameterValue {
    var description: String {
        return value
    }
}
