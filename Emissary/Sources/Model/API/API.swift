//
//  API.swift
//  Emissary
//
//  Created by Jordan Kay on 10/22/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

public typealias BasicTask = Task<Void, Void, NetworkError>

public protocol API {
    associatedtype ParameterNames: ParameterName = DefaultParameterNames
    associatedtype ErrorType: Error & Decodable
    
    var customBaseURL: URL? { get }
    var authorization: Authorization? { get }
    var customHeaderParameters: [Parameter<ParameterNames>] { get }
    var apiKey: Parameter<ParameterNames>? { get }
    
    static var baseURL: URL { get }
    static var responseFormat: ResponseFormat { get }
    static var dateFormat: String? { get }
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy { get }
    
    static func indicateRequestActive(_ active: Bool)
}

public extension API {
    var customBaseURL: URL? { return nil }
    var authorization: Authorization? { return nil }
    var customHeaderParameters: [Parameter<ParameterNames>] { return [] }
    var apiKey: Parameter<ParameterNames>? { return nil }
    
    static var responseFormat: ResponseFormat { return .plain }
    static var dateFormat: String? { return nil }
    
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        return dateFormatter.map(JSONDecoder.DateDecodingStrategy.formatted) ?? .iso8601
    }
    
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
        return dateFormatter.map(JSONEncoder.DateEncodingStrategy.formatted) ?? .iso8601
    }
    
    func getResource<Resource: Decodable>(at path: Path) -> Task<Void, Resource, NetworkError> {
        return request(method: .get, path: path, parse: Self.parse)
    }
    
    func getResources<Resource: Decodable & Collection>() -> Task<Void, Resource, NetworkError> where Resource.Element: PathAccessible {
        let path = Resource.Element.path
        return request(method: .get, path: path, parse: Self.parse)
    }
    
    func getResources<Resource: Decodable & Collection, ResourceParameterNames>(specifiedBy parameters: [Parameter<ResourceParameterNames>]) -> Task<Void, Resource, NetworkError> where Resource.Element: PathAccessible {
        let path = Resource.Element.path
        let queryItems = parameters.map(URLQueryItem.init)
        return request(method: .get, path: path, queryItems: queryItems, parse: Self.parse)
    }
    
    func post<Progress>(to path: Path) -> Task<Progress, Void, NetworkError> {
        return request(method: .post, path: path) { _ in }
    }
    
    func post<Progress, ResourceParameterNames>(to path: Path, specifying parameters: [Parameter<ResourceParameterNames>]) -> Task<Progress, Void, NetworkError> {
        let queryItems = parameters.map(URLQueryItem.init)
        return request(method: .post, path: path, queryItems: queryItems) { _ in }
    }
    
    func postResource<Resource: Encodable, Progress>(_ resource: Resource, at path: Path) -> Task<Progress, Void, NetworkError> {
        let payload = Payload(for: resource)
        return request(method: .post, path: path, payload: payload) { _ in }
    }
    
    func postResource<Resource: Encodable, ReturnedResource: Decodable, Progress>(_ resource: Resource, at path: Path) -> Task<Progress, ReturnedResource, NetworkError> {
        let payload = Payload(for: resource)
        return request(method: .post, path: path, payload: payload, parse: Self.parse)
    }
    
    func postResource<Resource: Encodable, ReturnedResource: Decodable & PathAccessible, Progress>(_ resource: Resource) -> Task<Progress, ReturnedResource, NetworkError> {
        let path = ReturnedResource.path
        let payload = Payload(for: resource)
        return request(method: .post, path: path, payload: payload, parse: Self.parse)
    }
    
    func putResource<Resource: Encodable, ReturnedResource: Decodable>(_ resource: Resource, at path: Path) -> Task<Void, ReturnedResource, NetworkError> {
        let payload = Payload(for: resource)
        return request(method: .put, path: path, payload: payload, parse: Self.parse)
    }
    
    func deleteResource(at path: Path) -> BasicTask {
        return request(method: .delete, path: path) { _ in }
    }
    
    func deleteResource<Resource: PathAccessible>(ofType type: Resource.Type) -> BasicTask {
        let path = type.path
        return request(method: .delete, path: path) { _ in }
    }
}

private extension API {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return decoder
    }
    
    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = dateEncodingStrategy
        return encoder
    }
    
    static var dateFormatter: DateFormatter? {
        return dateFormat.map(DateFormatter.init)
    }
    
    func headers(for payload: Payload?) -> [Header] {
        var headers: [Header] = [.accept(.encoded(.json))]
        
        payload.map {
            headers += $0.headers
        }
        authorization.map {
            headers.append(.authorization($0))
        }
        customHeaderParameters.forEach {
            headers.append(.custom(key: $0.key.rawValue, value: $0.value))
        }
        
        return headers
    }
    
    func request<Resource, Progress>(method: Method, path: Path, queryItems: [URLQueryItem] = [], payload: Payload? = nil, parse: @escaping (Data) throws -> Resource) -> Task<Progress, Resource, NetworkError> {
        let baseURL = customBaseURL ?? Self.baseURL
        let headers = self.headers(for: payload)
        let body = payload?.body(Self.encoder)
        let request = URLRequest(baseURL: baseURL, path: path, method: method, headers: headers, queryItems: queryItems, body: body)
        
        return Task { _, fulfill, reject, configure in
            let completionHandler = Self.completionHandler(fulfill: fulfill, reject: reject, parse: parse)
            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)

            Self.indicateRequestActive(true)
            dataTask.resume()
        }
    }
    
    static func completionHandler<Resource>(fulfill: @escaping (Resource) -> Void, reject: @escaping (NetworkError) -> Void, parse: @escaping (Data) throws -> Resource) -> (Data?, URLResponse?, Error?) -> Void {
        return { data, response, error in
            let completion: () -> Void
            do {
                let data = try process(data, with: response)
                let resource = try parse(data)
                completion = { fulfill(resource) }
            } catch {
                completion = { reject(error as! NetworkError) }
            }
            DispatchQueue.main.async {
                completion()
                indicateRequestActive(false)
            }
        }
    }
    
    static func process(_ data: Data?, with response: URLResponse?) throws -> Data {
        guard let data = data else {
            throw NetworkError.noData
        }
        guard let response = response as? HTTPURLResponse, case let statusCode = response.representedStatusCode else {
            throw NetworkError.noResponse
        }
        guard statusCode.category == .success else {
            throw NetworkError.noSuccessStatusCode(statusCode, nil)
        }
        return data
    }
    
    static func parse<Resource: Decodable>(_ data: Data) throws -> Resource {
        do {
            switch responseFormat {
            case .plain:
                return try decoder.decode(Resource.self, from: data)
            case .jsonAPI:
                return try decoder.decode(Wrapper<Resource>.self, from: data).data
            }
        } catch {
            throw NetworkError.couldNotParseData(data, error)
        }
    }
}

private extension URLQueryItem {
    init<T>(parameter: Parameter<T>) {
        self.init(name: parameter.key.rawValue, value: parameter.value)
    }
}
