//
//  File.swift
//  Emissary
//
//  Created by Jordan Kay on 9/20/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

public extension URL {
    var mimeType: String? {
        guard
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue(),
            !pathExtension.isEmpty else { return nil }
        return mimeType as String
    }
}
