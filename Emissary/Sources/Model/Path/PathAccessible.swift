//
//  PathAccessible.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol PathAccessible: SubpathRepresentable {}

public extension PathAccessible {
    var pathToResource: Path {
        return .init(components: subpathToResource.components)
    }
    
    static var path: Path {
        return .init(components: subpath.components)
    }
    
    static func path(to string: String) -> Path {
        let subpath = self.subpath(to: string)
        return .init(components: subpath.components)
    }
    
    static func path(to pathComponent: PathComponents) -> Path {
        let subpath = self.subpath(to: pathComponent)
        return .init(components: subpath.components)
    }
}
