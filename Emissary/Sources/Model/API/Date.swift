//
//  Date.swift
//  Model
//
//  Created by Jordan Kay on 4/24/19.
//  Copyright © 2019 CultivR. All rights reserved.
//

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        locale = .init(identifier: "en_US_POSIX")
        timeZone = TimeZone(secondsFromGMT: 0)
        self.dateFormat = dateFormat
    }
}
