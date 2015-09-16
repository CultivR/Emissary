//
//  DefaultParameterNames.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public struct DefaultParameterNames: ParameterName {
    public let rawValue: String
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}
