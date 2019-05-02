//
//  AuthorizationError.swift
//  Model
//
//  Created by Jordan Kay on 5/2/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public enum AuthorizationError {
    case error
}

extension AuthorizationError: Error {}

extension AuthorizationError: Decodable {
    public init(from decoder: Decoder) throws {
        self = .error
    }
}
