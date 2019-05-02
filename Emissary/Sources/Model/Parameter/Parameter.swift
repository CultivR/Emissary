//
//  Parameter.swift
//  Emissary
//
//  Created by Jordan Kay on 8/30/18.
//  Copyright © 2018 CultivR. All rights reserved.
//

public struct Parameter<Name: ParameterName> {    
    private let name: Name
    private let value: ParameterValue
}

extension Parameter {
    var nameString: String {
        return name.rawValue
    }
    
    var valueString: String {
        return value.description
    }
    
    func valueString(with formatter: Formatter) -> String {
        return (value as? Date).flatMap(formatter.string) ?? value.description
    }
}

extension Parameter: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Name, ParameterValue)...) {
        let (name, value) = elements.first!
        self.init(name: name, value: value)
    }
}
