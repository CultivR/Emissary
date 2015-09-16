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

public func +(lhs: Path, rhs: Subpath) -> Path {
    return .init(components: lhs.components + rhs.components)
}

private extension String {
    static let slash = "/"
}
