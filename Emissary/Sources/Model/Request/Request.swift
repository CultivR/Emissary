//
//  Request.swift
//  Emissary
//
//  Created by Jordan Kay on 9/17/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

extension URLRequest {
    init(baseURL: URL, path: Path, method: Method, headers: [Header], queryItems: [URLQueryItem], body: Data?) {
        let pathComponent = path.stringValue
        let url = baseURL.appendingPathComponent(pathComponent)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        if queryItems.count > 0 {
            components.queryItems = queryItems
        }
        
        self.init(url: components.url!)
        
        httpBody = body
        httpMethod = method.rawValue
        headers.forEach {
            setValue($0.value, forHTTPHeaderField: $0.field)
        }
    }
}
