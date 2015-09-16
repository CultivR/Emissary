//
//  PathComponent.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol PathComponent {
    init?(rawValue: String)
    
    var rawValue: String { get }
}

extension String: PathComponent {
    public init?(rawValue: String) {
        self = rawValue
    }
    
    public var rawValue: String {
        return self
    }
}
