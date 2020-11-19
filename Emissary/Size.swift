//
//  Size.swift
//  Emissary
//
//  Created by Jordan Kay on 11/6/17.
//  Copyright © 2017 Cultivr. All rights reserved.
//

public protocol Size: RawRepresentable {
    static var key: String { get }
}

enum DefaultSize: String {
    case `default`
}

extension DefaultSize: Size {
    static var key: String {
        fatalError()
    }
}
