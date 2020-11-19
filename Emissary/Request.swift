//
//  Request.swift
//  Emissary
//
//  Created by Jordan Kay on 9/17/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

extension URLRequest {
    init<T>(baseURL: URL, resource: Resource<T>, pathUsesTrailingSlash: Bool, headers: [Header], queryItems: [URLQueryItem]) {
        let fullURL: URL
        let pathComponent = resource.path.string(trailingSlash: pathUsesTrailingSlash)
        let url = baseURL.appendingPathComponent(pathComponent)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        if queryItems.count > 0 {
            components.queryItems = queryItems
        }
        
        let componentsURL = components.url!
        if url.scheme == "file" {
            var filePathComponent = pathComponent
            if let query = componentsURL.query {
                filePathComponent += "?" + query
            }
            let escapedFilePathComponent = filePathComponent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            fullURL = baseURL.appendingPathComponent(escapedFilePathComponent)
        } else {
            fullURL = componentsURL
        }
        self.init(url: fullURL)
        
        httpMethod = resource.method.rawValue
        httpBody = resource.requestBody
        cachePolicy = resource.useCached ? .returnCacheDataElseLoad : .useProtocolCachePolicy
        
        let allHeaders = headers + resource.headers
        for header in allHeaders {
            setValue(header.value, forHTTPHeaderField: header.field)
        }
    }
}

public struct RequestData {
    let body: Data?
    let headers: [Header]
    
    public init(items: [Any]) {
        self.init(json: items)
    }
    
    public init(parameters: [String: Any]) {
        self.init(json: parameters)
    }
    
    public init(urlEncodedParameters: [String: Any]) {
        let string = Array<(key: String, value: Any)>(urlEncodedParameters).map { key, value in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        let bodyString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        body = bodyString.data(using: .utf8)
        headers = [.contentType(.encoded(.url))]
    }
    
    public init(fieldName: String?, sourceFile: URL?, parameters: [String: String]? = nil) {
        let boundary = String(randomStringOfLength: .boundaryLength)
        
        var headers: [Header] = []
        headers.append(.contentType(.multiPartFormData(boundary: boundary)))
        
        body = Data(requestBodyForFile: sourceFile, fieldName: fieldName, parameters: parameters, boundary: "--\(boundary)")
        self.headers = headers
    }
    
    private init(json: Any) {
        let contentType: ContentType = .encoded(.json)
        body = try! JSONSerialization.data(withJSONObject: json)
        headers = [
            .accept(contentType),
            .contentType(contentType),
            .contentLength(body!.count),
        ]
    }
}

private extension Data {
    init?(requestBodyForFile file: URL?, fieldName: String?, parameters: [String: String]?, boundary: String) {
        var body = Data()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                body += boundary
                body += .contentDisposition(.formData(name: key, filename: nil))
                body += .clrf
                body += value
            }
        }
        
        if let file = file, let fieldName = fieldName {
            guard let mimeType = file.mimeType else { return nil }
            
            let filename = file.lastPathComponent
            let data = try! Data(contentsOf: URL(fileURLWithPath: file.path))
            body += boundary
            body += .contentDisposition(.formData(name: fieldName, filename: filename))
            body += .contentType(.mimeType(mimeType))
            body += .clrf
            body += data
            body += boundary
        }
        
        self = body
    }
}

private func +=(lhs: inout Data, rhs: Data) {
    lhs.append(rhs)
    lhs += ""
}

private func +=(lhs: inout Data, rhs: String) {
    let string: String = rhs + .clrf
    let data = string.data(using: .utf8)!
    lhs.append(data)
}

private func +=(lhs: inout Data, rhs: Header) {
    let data = rhs.description.data(using: .utf8)!
    lhs.append(data)
}

private extension String {
    static let clrf = "\r\n"
    
    init(randomStringOfLength length: Int) {
        var length = length
        let uuid = CFUUIDCreate(nil)
        let nonce = CFUUIDCreateString(nil, uuid) as String
        length = Swift.min(length, nonce.count)
        
        let start = nonce.startIndex
        let end = nonce.index(start, offsetBy: length)
        self.init(String(nonce[start..<end]))
    }
}

private extension Int {
    static let boundaryLength = 16
}
