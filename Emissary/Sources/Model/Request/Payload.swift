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
    
    init<ParameterNames: ParameterName>(urlEncodedParameters: [Parameter<ParameterNames>]) {
        let string = urlEncodedParameters.map { "\($0.nameString)=\($0.valueString)" }.joined(separator: "&")
        let bodyString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        body = { _ in bodyString.data(using: .utf8)! }
        headers = [.contentType(.encoded(.url))]
    }
}
