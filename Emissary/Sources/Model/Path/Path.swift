//
//  Path.swift
//  Emissary
//
//  Created by Jordan Kay on 11/20/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

public struct Path {
    let components: [PathComponent]
}

extension Path {
    var stringValue: String {
        return components.map { $0.rawValue }.joined(separator: .slash)
    }
}

extension Path: SubpathAppendable {
    public func appending(_ subpath: Subpath) -> Path {
        return .init(components: components + subpath.components)
    }
}

private extension String {
    static let slash = "/"
}
