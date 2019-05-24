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
    
    func pathToResource(to pathComponent: PathComponents) -> Path {
        let subPath = subpathToResource(to: pathComponent)
        return .init(components: subPath.components)
    }
    
    static var path: Path {
        return .init(components: subpath.components)
    }
    
    static func path(to pathComponent: PathComponents) -> Path {
        let subpath = self.subpath(to: pathComponent)
        return .init(components: subpath.components)
    }
    
    static func path<Value: CustomStringConvertible>(to value: Value, to pathComponents: PathComponents...) -> Path {
        let subpath = self.subpath(to: value, to: pathComponents)
        return .init(components: subpath.components)
    }
}
