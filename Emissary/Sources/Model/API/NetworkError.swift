//
//  Reason.swift
//  Emissary
//
//  Created by Jordan Kay on 9/17/15.
//  Copyright © 2015 CultivR. All rights reserved.
//

public enum NetworkError: Error {
    case noResponse
    case noData
    case couldNotParseData(Data, Error)
    case noSuccessStatusCode(HTTPURLResponse.StatusCode, Error?)
}

// MARK: -
extension NetworkError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noResponse:
            return "No Response"
        case .noData:
            return "No Data"
        case let .couldNotParseData(_, error):
            return String(describing: error)
        case let .noSuccessStatusCode(statusCode, _):
            return statusCode.description
        }
    }
}
