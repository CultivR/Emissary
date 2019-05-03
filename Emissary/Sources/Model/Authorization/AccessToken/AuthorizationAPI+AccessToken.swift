//
//  AuthorizationAPI+AccessToken.swift
//  Model
//
//  Created by Jordan Kay on 5/2/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public extension AuthorizationAPI {
    typealias AccessTokenTask = Task<Void, AccessToken, NetworkError>
    
    func authorize() -> AccessTokenTask {
        let accessToken = AccessToken.retrieveFromKeychain()
        return accessToken.map(Task.init) ?? fetchAuthorizationCode().success(createSession)
    }
}

private extension AuthorizationAPI {
    typealias AuthorizationCodeTask = Task<Void, AuthorizationCode, NetworkError>

    func fetchAuthorizationCode() -> AuthorizationCodeTask {
        let path = AuthorizationType.path
        let parameters = AuthorizationType.parameters(clientID: Self.clientID, redirectURI: Self.redirectURI)
        let queryItems = parameters.map(queryItem)
        let url = URL(baseURL: Self.baseURL, path: path, queryItems: queryItems)
        
        return Task { _, fulfill, reject, _ in
            let completionHandler = Self.completionHandler(fulfill: fulfill, reject: reject)
            session = SFAuthenticationSession(url: url, callbackURLScheme: nil, completionHandler: completionHandler)
            session?.start()
        }
    }
    
    func createSession(using authorizationCode: AuthorizationCode) -> AccessTokenTask {
        let path = AccessToken.path
        let parameters = AccessToken.parameters(clientID: Self.clientID, authorizationCode: authorizationCode, redirectURI: Self.redirectURI)
        let success: (AccessToken) -> Void = { $0.storeInKeychain() }
        return post(to: path, specifying: parameters).on(success: success, failure: nil)
    }
    
    static func completionHandler(fulfill: @escaping (AuthorizationCode) -> Void, reject: @escaping (NetworkError) -> Void) -> SFAuthenticationSession.CompletionHandler {
        return { url, error in
            guard
                let url = url,
                let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false),
                let queryItems = components.queryItems,
                let queryItem = queryItems.first, queryItem.name == AuthorizationResponseType.code.rawValue,
                let authorizationCode = queryItem.value.map(AuthorizationCode.init) else {
                    reject(.noResponse)
                    return
            }
            fulfill(authorizationCode)
        }
    }
}

private var session: SFAuthenticationSession?
