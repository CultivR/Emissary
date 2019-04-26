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

extension Subpath: SubpathAppendable {
    public func appending(_ subpath: Subpath) -> Subpath {
        return .init(components: components + subpath.components)
    }
}
