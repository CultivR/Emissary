//
//  ContentType.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

enum ContentType {
    case encoded(Encoding)
    case multiPartFormData(boundary: String)
    case mimeType(MIMEType)
}

extension ContentType: CustomStringConvertible {
    var description: String {
        switch self {
        case let .encoded(encoding):
            return "application/\(encoding.rawValue)"
        case let .multiPartFormData(boundary):
            return "multipart/form-data; boundary=\(boundary)"
        case let .mimeType(type):
            return "image/\(type.rawValue)"
        }
    }
}
