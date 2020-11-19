//
//  Parameter.swift
//  Emissary
//
//  Created by Jordan Kay on 8/30/18.
//  Copyright © 2018 Squareknot. All rights reserved.
//

public typealias Parameters = [String: Any]
public typealias QueryParameters = [Parameter]

public struct Parameter {
    let key: String
    let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

extension Parameter: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        let (key, value) = elements.first!
        self.init(key: key, value: value)
    }
}
