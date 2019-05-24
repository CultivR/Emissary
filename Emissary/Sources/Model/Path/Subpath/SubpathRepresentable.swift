//
//  SubpathRepresentable.swift
//  Emissary
//
//  Created by Jordan Kay on 3/13/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol SubpathRepresentable {
    typealias PathID = CustomStringConvertible
    
    associatedtype PathComponents: PathComponent
    
    var pathID: PathID? { get }
    
    static var component: PathComponents { get }
}

public extension SubpathRepresentable {
    var pathID: PathID? {
        return nil
    }
    
    var subpathToResource: Subpath {
        let pathIDString = pathID.map { String(describing: $0) }
        let components = ([Self.component, pathIDString] as [PathComponent?]).compactMap { $0 }
        return .init(components: components)
    }
    
    func subpathToResource(to pathComponent: PathComponents) -> Path {
        return .init(components: subpathToResource.components + [pathComponent])
    }
    
    static var subpath: Subpath {
        return .init(components: [component])
    }
    
    static func subpath(to pathComponent: PathComponents) -> Subpath {
        let components = [Self.component, pathComponent]
        return .init(components: components)
    }
    
    static func subpath<Value: CustomStringConvertible>(to value: Value, to pathComponents: PathComponents...) -> Subpath {
        return subpath(to: value, to: pathComponents)
    }
}

extension SubpathRepresentable {
    static func subpath<Value: CustomStringConvertible>(to value: Value, to pathComponents: [PathComponents]) -> Subpath {
        let string = String(describing: value)
        let components: [PathComponent] = [Self.component, string] + pathComponents
        return .init(components: components)
    }
}
