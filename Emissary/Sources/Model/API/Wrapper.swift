//
//  Wrapper.swift
//  Emissary
//
//  Created by Jordan Kay on 4/24/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

struct Wrapper<DataType: Decodable> {
    let data: DataType
}

extension Wrapper: Decodable {}
