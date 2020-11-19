//
//  Activity.swift
//  Emissary
//
//  Created by Jordan Kay on 11/23/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

private let app = UIApplication.shared
private var requestCount = 0

func startIndicatingNetworkActivity() {
    DispatchQueue.main.async {
        requestCount += 1
        if requestCount == 1 {
            app.isNetworkActivityIndicatorVisible = true
        }
    }
}

func stopIndicatingNetworkActivity() {
    DispatchQueue.main.async {
        requestCount -= 1
        if requestCount == 0 {
            app.isNetworkActivityIndicatorVisible = false
        }
    }
}
