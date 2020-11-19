//
//  API.swift
//  Emissary
//
//  Created by Jordan Kay on 10/22/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

public typealias BasicTask = Task<Float, Void, Reason>

public protocol API {
    var customBaseURL: URL? { get }
    var authToken: AuthToken? { get }
    var authorization: Authorization? { get }
    var customHeaderParameters: [String: String]? { get }
    var apiKey: Parameter? { get }
    
    static var baseURL: URL! { get }
    static var responseFormat: ResponseFormat { get }
    static var dateFormat: String? { get }
    static var injectedScheme: String? { get }
    static var containerKeyPath: KeyPath? { get }
    static var pathsUseTrailingSlash: Bool { get }
    static var requestsUseContainerKeyPath: Bool { get }
}

public enum ResponseFormat {
    case json
    case xml
}

public extension API {
    var customBaseURL: URL? { return nil }
    var authToken: AuthToken? { return nil }
    var authorization: Authorization? { return nil }
    var customHeaderParameters: [String: String]? { return nil }
    var apiKey: Parameter? { return nil }
    
    var timestamp: Int64 {
        let interval = NSDate().timeIntervalSince1970
        return Int64(interval * 1000)
    }
    
    var incrementedTimestamp: Int64 {
        return timestamp + 1
    }
    
    static var responseFormat: ResponseFormat { return .json }
    static var dateFormat: String? { return nil }
    static var injectedScheme: String? { return nil }
    static var containerKeyPath: KeyPath? { return nil }
    static var pathsUseTrailingSlash: Bool { return false }
    static var requestsUseContainerKeyPath: Bool { return false }
    
    func request<T>(_ resource: Resource<T>, withInitialDelay initialDelay: TimeInterval? = nil) -> Task<Float, T, Reason> {
        return Task { progress, fulfill, reject, configure in
            guard let baseURL = self.customBaseURL ?? Self.baseURL else {
                reject(.invalidBaseURL)
                return
            }
            
            self.startDataTask(baseURL: baseURL, resource: resource, progress: progress, fulfill: fulfill, reject: reject, configure: configure, initialDelay: initialDelay)
        }
    }
    
    func containedResource<T: Decodable>(path: Path, queryParameters: [Parameter]? = nil, data: RequestData? = nil, method: Emissary.Method) -> Resource<T> {
        return .init(path: path, queryParameters: queryParameters, data: data, containerKeyPath: Self.containerKeyPath, method: method)
    }
    
    func containedResource<T: Decodable>(path: Path, queryParameters: [Parameter]? = nil, data: RequestData? = nil, method: Emissary.Method) -> Resource<[T]> {
        return .init(path: path, queryParameters: queryParameters, data: data, containerKeyPath: Self.containerKeyPath, method: method)
    }
    
    static func setupDecoding() {
        if let dateFormatter = dateFormatter {
            Date.decoder = { json in
                guard let string = json as? String else {
                    throw DecodingError.typeMismatch(expected: String.self, actual: type(of: json), .init(object: json))
                }
                return dateFormatter.date(from: string)!
            }
        }
        if let scheme = injectedScheme {
            URL.decoder = { json in
                guard let string = json as? String else {
                    throw DecodingError.typeMismatch(expected: String.self, actual: type(of: json), .init(object: json))
                }
                
                guard let components = NSURLComponents(string: string) else {
                    throw DecodingError.typeMismatch(expected: URL.self, actual: type(of: json), .init(object: json))
                }
                
                components.scheme = scheme
                return URL(string: components.string!)!
            }
        }
    }
}

private extension API {
    static var dateFormatter: DateFormatter? {
        guard let dateFormat = dateFormat else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = dateFormat
        return formatter
    }

    func startDataTask<T>(baseURL: URL, resource: Resource<T>, progress: @escaping (Float) -> Void, fulfill: @escaping (T) -> Void, reject: @escaping (Reason) -> Void, configure: TaskConfiguration, initialDelay: TimeInterval?) {
        let trailingSlash = Self.pathsUseTrailingSlash
        var path = "\(baseURL.path)/\(resource.path.string(trailingSlash: trailingSlash))"
        var queryItems = resource.queryItems ?? []
        apiKey.do { queryItems.append(.init(name: $0.key, value: $0.value)) }
        if queryItems.count > 0 {
            path += "?" + queryItems.map { "\($0.name)=\($0.value!)" }.joined(separator: "&")
        }
        
        var headers: [Header] = []
        authorization.do { headers.append(.authorization($0)) }
        customHeaderParameters.do {
            for (key, value) in $0 {
                headers.append(.custom([key: value]))
            }
        }
        
        let request = URLRequest(baseURL: baseURL, resource: resource, pathUsesTrailingSlash: trailingSlash, headers: headers, queryItems: queryItems)
        let task = dataTask(request: request, resource: resource, process: processData, fulfill: fulfill, reject: reject)
        let startTask = {
            print("\(resource.method.rawValue) \(path) HTTP/1.1")
            request.allHTTPHeaderFields?.forEach { print("\($0): \($1)") }
            baseURL.host.do { print("Host: \($0)") }
            resource.requestBody.do { print(String(data: $0, encoding: .utf8)!) }
            task.resume()
        }
        
        let delayedTask = initialDelay.map { _ in DispatchWorkItem(block: startTask) }
        if let delayedTask = delayedTask {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + initialDelay!, execute: delayedTask)
        } else {
            startTask()
        }
        
        startIndicatingNetworkActivity()
        configure.pause = { [weak task] in task?.suspend() }
        configure.resume = { [weak task] in task?.resume() }
        configure.cancel = { [weak task] in
            stopIndicatingNetworkActivity()
            if task?.state == .running {
                task?.cancel()
            } else {
                delayedTask?.cancel()
            }
        }
    }
    
    func processData(data: Data) throws -> Any {
        switch Self.responseFormat {
        case .json:
            guard data.count > 0 else { return [:] }
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print("\(json)\n")
            
            if let keyPath = Self.containerKeyPath, Self.requestsUseContainerKeyPath {
                return try json => keyPath
            }
            return json
        case .xml:
            return 0
        }
    }
}

private extension URL {
    var stringWithoutTrailingSlash: String {
        let offset = absoluteString.hasSuffix("/") ? -1 : 0
        let endIndex = absoluteString.index(absoluteString.endIndex, offsetBy: offset)
        return String(absoluteString[..<endIndex])
    }
}
