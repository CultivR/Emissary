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
