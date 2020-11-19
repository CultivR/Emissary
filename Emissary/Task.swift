//
//  Task.swift
//  Emissary
//
//  Created by Jordan Kay on 9/4/18.
//  Copyright © 2018 Squareknot. All rights reserved.
//

public extension Task where Progress == Float, Value == Void, Error == Reason {
    static var noop: BasicTask {
        return Task(value: ())
    }
}
