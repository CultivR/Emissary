//
//  Parameter.swift
//  Emissary
//
//  Created by Jordan Kay on 8/30/18.
//  Copyright © 2018 CultivR. All rights reserved.
//

public struct Parameter<ParameterNames: ParameterName> {
    let key: ParameterNames
    let value: String
}

extension Parameter: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (ParameterNames, String)...) {
        let (key, value) = elements.first!
        self.init(key: key, value: value)
    }
}
