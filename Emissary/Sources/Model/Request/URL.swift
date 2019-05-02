//
//  URL.swift
//  Model
//
//  Created by Jordan Kay on 5/1/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

extension URL {
    init(baseURL: URL, path: Path, queryItems: [URLQueryItem]) {
        let pathComponent = path.stringValue
        let url = baseURL.appendingPathComponent(pathComponent)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        if queryItems.count > 0 {
            components.queryItems = queryItems
        }
        
        self = components.url!
    }
}
