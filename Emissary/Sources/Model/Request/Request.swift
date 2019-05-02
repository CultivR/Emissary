//
//  Request.swift
//  Emissary
//
//  Created by Jordan Kay on 9/17/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

extension URLRequest {
    init(baseURL: URL, path: Path, method: Method, headers: [Header], queryItems: [URLQueryItem], body: Data?) {        
        let url = URL(baseURL: baseURL, path: path, queryItems: queryItems)
        self.init(url: url)
        
        httpBody = body
        httpMethod = method.rawValue
        headers.forEach {
            setValue($0.value, forHTTPHeaderField: $0.field)
        }
    }
}
