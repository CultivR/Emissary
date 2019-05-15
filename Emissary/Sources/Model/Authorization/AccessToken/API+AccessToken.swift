//
//  API+AccessToken.swift
//  Emissary
//
//  Created by Jordan Kay on 5/15/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public extension API where AuthorizationStandardType: PathAccessible {
    func deauthorize() -> BasicTask {
        let subpath = AccessToken.subpath
        let path = AuthorizationStandardType.path.appending(subpath)
        let success: () -> Void = { AccessToken.removeFromKeychain() }
        return deleteResource(at: path).on(success: success, failure: nil)
    }
}
