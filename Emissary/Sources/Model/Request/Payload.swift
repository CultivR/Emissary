//
//  RequestBody.swift
//  Emissary
//
//  Created by Jordan Kay on 3/22/19.
//  Copyright © 2019 Cultivr. All rights reserved.
//

public struct Payload {
    let body: (JSONEncoder) -> Data
    let headers: [Header]
}

public extension Payload {
    init<Resource: Encodable>(for value: Resource) {
        body = { try! $0.encode(value) }
        headers = [.contentType(.encoded(.json))]
    }
}
