//
//  ContentType.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

enum ContentType {
    case encoded(Encoding)
}

extension ContentType: CustomStringConvertible {
    var description: String {
        switch self {
        case let .encoded(encoding):
            return "application/\(encoding.rawValue)"
        }
    }
}
