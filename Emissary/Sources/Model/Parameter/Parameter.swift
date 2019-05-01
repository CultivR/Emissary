//
//  Parameter.swift
//  Emissary
//
//  Created by Jordan Kay on 8/30/18.
//  Copyright © 2018 CultivR. All rights reserved.
//

public struct Parameter<ParameterNames: ParameterName> {
    public typealias Value = CustomStringConvertible
    
    private let key: ParameterNames
    private let value: Value
}

extension Parameter {
    var keyName: String {
        return key.rawValue
    }
    
    func valueName(with formatter: Formatter) -> String {
        return (value as? Date).flatMap(formatter.string) ?? value.description
    }
}

extension Parameter: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (ParameterNames, Value)...) {
        let (key, value) = elements.first!
        self.init(key: key, value: value)
    }
}
