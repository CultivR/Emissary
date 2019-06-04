//
//  Method.swift
//  Emissary
//
//  Created by Jordan Kay on 9/17/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

public enum Method: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: -
extension Method: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}
