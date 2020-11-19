//
//  Video.swift
//  Emissary
//
//  Created by Jordan Kay on 8/30/16.
//  Copyright © 2016 Cultivr. All rights reserved.
//

import AVFoundation
import SwiftTask

private var urlKey = "url"

extension ImageDisplaying {
    public func setVideoThumbnailURL(_ url: URL, animated: Bool = false) {
        objc_setAssociatedObject(self, &urlKey, url, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        if let image = cachedImage(forURL: url) {
            setImage(image, update: true, animated: animated)
        } else {
            setImage(nil, update: true, animated: false)
            fetchCachedImage(forURL: url).success { image in
                DispatchQueue.main.async {
                    cacheImage(image, forURL: url, toDisk: false)
                    self.setImage(image, update: true, animated: animated)
                }
            }.failure { _ in
                DispatchQueue.global(qos: .background).async {
                    let asset = AVAsset(url: url)
                    let generator = AVAssetImageGenerator(asset: asset)
                    let time = CMTime(seconds: 0, preferredTimescale: 1)
                    let scale = UIScreen.main.scale
                    generator.appliesPreferredTrackTransform = true
                    generator.maximumSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
                    
                    startIndicatingNetworkActivity()
                    let imageRef = try? generator.copyCGImage(at: time, actualTime: nil)
                    stopIndicatingNetworkActivity()
                    if let imageRef = imageRef {
                        let image = UIImage(cgImage: imageRef, scale: scale, orientation: .up)
                        DispatchQueue.main.async {
                            cacheImage(image, forURL: url, toDisk: true)
                            let existingURL = objc_getAssociatedObject(self, &urlKey) as? URL
                            if url == existingURL {
                                self.setImage(image, update: true, animated: animated)
                            }
                        }
                    }
                }
            }
        }
    }
}
