//
//  Task.swift
//  Emissary
//
//  Created by Jordan Kay on 10/4/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

typealias Process = (Data) throws -> Any
typealias Handler = (Data?, URLResponse?, Error?) -> Void

func dataTask<T>(request: URLRequest, resource: Resource<T>?, process: @escaping Process, fulfill: @escaping (T) -> Void, reject: @escaping (Reason) -> Void) -> URLSessionDataTask {
    let cachedResponse = resource?.useCached == true && URLCache.shared.cachedResponse(for: request) != nil && !request.url!.isFileURL
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        do {
            let processedData = try analyze(data: data, response: response, error: error, process: process, cachedResponse: cachedResponse)
            let result = try parse(data: processedData, resource: resource)
            DispatchQueue.main.async {
                fulfill(result)
            }
        } catch {
            DispatchQueue.main.async {
                reject(error as! Reason)
            }
        }
    }
    return task
}

private func analyze(data: Data?, response: URLResponse?, error: Error?, process: Process, cachedResponse: Bool) throws -> Any {
    let statusCode: HTTPURLResponse.StatusCode
    if let response = response as? HTTPURLResponse {
        statusCode = response.representedStatusCode
    } else if response?.url?.isFileURL == true {
        statusCode = .ok
    } else {
        throw Reason.connectivity(data, error)
    }

    print(statusCode)
    guard let data = data else {
        throw Reason.noData
    }

    let dataString = String(data: data, encoding: .utf8)
    if dataString != nil {
        print("Response\(cachedResponse ? " (cached)" : ""):")
    }
    
    guard statusCode.category == .success else {
         dataString.do { print("\($0)\n") }
        throw Reason.noSuccessStatusCode(statusCode, dataString)
    }
    
    let result: Any
    do {
        result = try process(data)
    } catch let error {
        dataString.do { print("\($0)\n") }
        throw Reason.couldNotProcessData(data, error)
    }
    return result
}

private func parse<T>(data: Any, resource: Resource<T>?) throws -> T {
    do {
        guard let result = try resource?.parse(data) ?? data as? T else {
            throw Reason.couldNotParseData(data, nil)
        }
        return result
    } catch {
        throw Reason.couldNotParseData(data, error)
    }
}
