//
//  Reason.swift
//  Emissary
//
//  Created by Jordan Kay on 9/17/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

public enum Reason: Error {
    case invalidBaseURL
    case noData
    case couldNotProcessData(Data, Error?)
    case couldNotParseData(Any, Error?)
    case noSuccessStatusCode(HTTPURLResponse.StatusCode, Any?)
    case connectivity(Data?, Error?)
}
