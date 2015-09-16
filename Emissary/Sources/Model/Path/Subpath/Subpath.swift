//
//  Subpath.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public struct Subpath {
    let components: [PathComponent]
}

public func +(lhs: Subpath, rhs: Subpath) -> Path {
    return .init(components: lhs.components + rhs.components)
}
