//
//  ParamaterValue.swift
//  Model
//
//  Created by Jordan Kay on 5/2/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol ParameterValue {
    var description: String { get }
}

public extension RawRepresentable where Self: ParameterValue, RawValue == String {
    var description: String {
        return rawValue
    }
}

extension String: ParameterValue {}

extension Date: ParameterValue {}

extension Int: ParameterValue {}
