//
//  ParameterArray.swift
//  Model
//
//  Created by Jordan Kay on 5/24/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public struct ParameterArray<Name: ParameterName> {
    public let parameters: [Parameter<Name>]
}

extension ParameterArray: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Name, [ParameterValue])...) {
        let (name, values) = elements.first!
        
        let parameters = values.enumerated().map {
            Parameter(name: name, value: $0.1, index: $0.0)
        }
        self.init(parameters: parameters)
    }
}
