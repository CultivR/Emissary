//
//  ContentDisposition.swift
//  Model
//
//  Created by Jordan Kay on 7/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

enum ContentDisposition {
    case formData(name: String, mimeType: MIMEType?)
}

// MARK: -
extension ContentDisposition: CustomStringConvertible {
    var description: String {
        switch self {
        case let .formData(name, mimeType):
            return "form-data; name=\"\(name)\"" + (mimeType.map { "; filename=\"file.\($0)\"" } ?? "")
        }
    }
}
