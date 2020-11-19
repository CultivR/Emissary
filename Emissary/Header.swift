//
//  Header.swift
//  Emissary
//
//  Created by Jordan Kay on 9/18/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

public enum Header {
    case accept(ContentType)
    case contentType(ContentType)
    case contentLength(Int)
    case contentDisposition(ContentDisposition)
    case authorization(Authorization)
    case custom(Parameter)
    
    var field: String {
        switch self {
        case .accept:
            return "Accept"
        case .contentType:
            return "Content-Type"
        case .contentLength:
            return "Content-Length"
        case .contentDisposition:
            return "Content-Disposition"
        case .authorization:
            return "Authorization"
        case let .custom(parameter):
            return parameter.key
        }
    }
    
    var value: String {
        switch self {
        case let .accept(value):
            return value.description
        case let .contentType(value):
            return value.description
        case let .contentLength(value):
            return value.description
        case let .contentDisposition(value):
            return value.description
        case let .authorization(value):
            return value.description
        case let .custom(parameter):
            return parameter.value
        }
    }
}

public protocol Value: CustomStringConvertible {}

public enum Authorization {
    case basic(username: String, password: String)
    case bearer(credentials: String)
    case jwt(token: String)
}

extension Authorization: Value {
    public var description: String {
        switch self {
        case let .basic(username, password):
            let data = "\(username):\(password)".data(using: .utf8)!
            let string = data.base64EncodedString()
            return "Basic \(string)"
        case let .bearer(credentials):
            return "Bearer \(credentials)"
        case let .jwt(token):
            return "JWT \(token)"
        }
    }
}

public enum ContentType {
    public enum Encoding: String {
        case url = "x-www-form-urlencoded"
        case json = "json"
    }

    case mimeType(String)
    case encoded(Encoding)
    case multiPartFormData(boundary: String)
}

extension ContentType: Value {
    public var description: String {
        switch self {
        case .mimeType(let mimeType):
            return mimeType
        case let .encoded(encoding):
            return "application/\(encoding)"
        case .multiPartFormData(let boundary):
            return description(withKey: "multipart/form-data", entries: ["boundary": boundary])
        }
    }
}

public enum ContentDisposition {
    case formData(name: String, filename: String?)
}

extension ContentDisposition: Value {
    public var description: String {
        switch self {
        case .formData(let name, let filename):
            return description(withKey: "form-data", entries: ["name": name], filename.map { ["filename": $0] })
        }
    }
}

extension Header: CustomStringConvertible {
    public var description: String {
        return "\(field): \(value)"
    }
}

private extension Value {
    func description(withKey key: String, entries: Entry?...) -> String {
        let strings = entries.flatMap { $0 }.map { "\($0.key)=\"\($0.value)\"" }
        return ([key] + strings).joined(separator: "; ")
    }
}

struct Entry: ExpressibleByDictionaryLiteral {
    let key: String
    let value: String
    
    init(dictionaryLiteral elements: (String, String)...) {
        key = elements[0].0
        value = elements[0].1
    }
}
