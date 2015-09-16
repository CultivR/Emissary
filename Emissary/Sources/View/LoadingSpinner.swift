//
//  LoadingSpinner.swift
//  Emissary
//
//  Created by Jordan Kay on 11/23/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

private var requestCount = 0

public extension API {
    static func indicateRequestActive(_ active: Bool) {
        let app = UIApplication.shared
        let increment = active ? 1 : -1
        let threshold = active ? 1 : 0
        
        DispatchQueue.main.async {
            requestCount += increment
            if requestCount == threshold {
                app.isNetworkActivityIndicatorVisible = active
            }
        }
    }
}
