//
//  Header.swift
//  Emissary
//
//  Created by Jordan Kay on 9/18/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

enum Header {
    case accept(ContentType)
    case contentType(ContentType)
    case contentLength(Int)
    case authorization(Authorization)
    case custom(key: String, value: String)
}

extension Header {
    var field: String {
        switch self {
        case .accept:
            return "Accept"
        case .contentType:
            return "Content-Type"
        case .contentLength:
            return "Content-Length"
        case .authorization:
            return "Authorization"
        case let .custom(key, _):
            return key
        }
    }
    
    var value: String {
        switch self {
        case let .accept(value), let .contentType(value):
            return value.description
        case let .contentLength(value):
            return value.description
        case let .authorization(value):
            return value.description
        case let .custom(_, value):
            return value
        }
    }
}

extension Header: CustomStringConvertible {
    var description: String {
        return "\(field): \(value)"
    }
}
