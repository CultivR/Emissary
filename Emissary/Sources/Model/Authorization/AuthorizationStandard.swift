//
//  AuthorizationStandard.swift
//  Emissary
//
//  Created by Jordan Kay on 5/15/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol AuthorizationStandard {}

// MARK: -
public enum BasicAuth: AuthorizationStandard {}

// MARK: -
public enum OAuth: AuthorizationStandard {}

extension OAuth: PathAccessible {
    public enum PathComponents: String, PathComponent {
        case oauth
    }
    
    // MARK: SubpathRepresentable
    public static var component: PathComponents {
        return .oauth
    }
}
