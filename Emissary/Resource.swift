//
//  Resource.swift
//  Emissary
//
//  Created by Jordan Kay on 9/17/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

public struct Resource<T> {
    let path: Path
    let queryItems: [URLQueryItem]?
    let requestBody: Data?
    let headers: [Header]
    let method: Method
    let useCached: Bool
    let parse: (Any) throws -> T
}

public extension Resource {
    init(path: Path, queryParameters: [Parameter]? = nil, data: RequestData? = nil, method: Method, useCached: Bool = false, parse: @escaping (Any) throws -> T) {
        self.path = path
        self.method = method
        self.useCached = useCached
        self.parse = parse
        
        requestBody = data?.body
        headers = data?.headers ?? []
        queryItems = queryParameters?.map { .init(name: $0.key, value: $0.value) }
    }
}

public extension Resource where T: Decodable {
    init(path: Path, queryParameters: [Parameter]? = nil, data: RequestData? = nil, containerKeyPath: KeyPath? = nil, method: Method, useCached: Bool = false) {
        self.init(path: path, queryParameters: queryParameters, data: data, method: method, useCached: useCached) { data in
            let json = try containerKeyPath.map { try data => $0 } ?? data
            return try T.decode(json)
        }
    }
}

public extension Resource where T: Collection, T.Element: Decodable {
    init(path: Path, queryParameters: [Parameter]? = nil, data: RequestData? = nil, containerKeyPath: KeyPath? = nil, method: Method, useCached: Bool = false) {
        self.init(path: path, queryParameters: queryParameters, data: data, method: method, useCached: useCached) { data in
            let json = try containerKeyPath.map { try data => $0 } ?? data
            guard
                let array = json as? [Any],
                let result = try (array.map { try T.Element.decode($0) } as? T) else {
                throw Reason.couldNotParseData(data, nil)
            }
            return result
        }
    }
}

