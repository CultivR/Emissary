//
//  String.swift
//  Model
//
//  Created by Jordan Kay on 5/2/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol StringRepresentable {
    init?(rawValue: String)
    
    var rawValue: String { get }
}
