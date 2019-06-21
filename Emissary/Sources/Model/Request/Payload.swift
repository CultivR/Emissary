//
//  RequestBody.swift
//  Emissary
//
//  Created by Jordan Kay on 3/22/19.
//  Copyright © 2019 Cultivr. All rights reserved.
//

public struct Payload {
    let body: (JSONEncoder) -> Data
    let headers: [Header]
}

public extension Payload {
    init<Resource: Encodable>(value: Resource) {
        body = { try! $0.encode(value) }
        headers = [.contentType(.encoded(.json))]
    }
    
    init<ParameterNames: ParameterName>(urlEncodedParameters: [Parameter<ParameterNames>]) {
        let string = urlEncodedParameters.map { "\($0.nameString)=\($0.valueString)" }.joined(separator: "&")
        let bodyString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        body = { _ in .init(bodyString.utf8) }
        headers = [.contentType(.encoded(.url))]
    }
    
    init<ParameterNames: ParameterName>(name: ParameterNames, value: UIImage) {
        let boundary = UUID().uuidString
        
        body = { _ in .init(name: name, image: value, boundary: boundary) }
        headers = [.contentType(.multiPartFormData(boundary: boundary))]
    }
}

// MARK: -
private extension Data {
    init<ParameterNames: ParameterName>(name: ParameterNames, image: UIImage, boundary: String) {
        var data = Data()
        let imageData = image.jpegData(compressionQuality: 0.1)!
        
        data += "--\(boundary)"
        data += .contentDisposition(.formData(name: name.rawValue, mimeType: .jpeg))
        data += .contentType(.mimeType(.jpeg))
        data += ""
        data += imageData
        data += "--\(boundary)--"
        
        self = data
    }
    
    static func +=(lhs: inout Data, rhs: Data) {
        lhs.append(rhs)
        lhs += ""
    }
    
    static func +=(lhs: inout Data, rhs: String) {
        let string: String = rhs + .clrf
        let data = Data(string.utf8)
        lhs.append(data)
    }
    
    static func +=(lhs: inout Data, rhs: Header) {
        let headerString = rhs.description + .clrf
        let data = Data(headerString.utf8)
        lhs.append(data)
    }
}

// MARK: -
private extension String {
    static let clrf = "\r\n"
}
