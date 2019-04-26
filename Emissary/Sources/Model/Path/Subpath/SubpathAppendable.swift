//
//  SubpathAppendable.swift
//  Model
//
//  Created by Jordan Kay on 4/26/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

public protocol SubpathAppendable {
    func appending(_ subpath: Subpath) -> Self
}
