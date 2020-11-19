//
//  Image.swift
//  Emissary
//
//  Created by Jordan Kay on 11/8/15.
//  Copyright © 2015 Cultivr. All rights reserved.
//

public typealias ImageTask = Task<Float, UIImage, Reason>

public protocol ImageDisplaying {
    var size: CGSize { get }
    var image: UIImage? { get }
    func setImage(_ image: UIImage?, update: Bool, animated: Bool)
}

public struct ImageResource<T: Size> {
    public let url: URL
    private let size: T?
    
    public init(url: URL, size: T? = nil) {
        self.url = url
        self.size = size
    }
    
    fileprivate var normalizedURL: URL {
        guard let size = size else { return url }
        
        let queryItem = URLQueryItem(name: type(of: size).key, value: "\(size)")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [queryItem]
        return components.url!
    }
}

@discardableResult public func request<T>(_ resource: ImageResource<T>) -> ImageTask {
    return Task { progress, fulfill, reject, configure in
        func process(data: Data) throws -> UIImage {
            guard let image = UIImage(data: data) else {
                throw Reason.couldNotProcessData(data, nil)
            }
            return image
        }

        let url = resource.normalizedURL
        let request = URLRequest(url: url)
        let task = dataTask(request: request, resource: nil, process: process, fulfill: fulfill, reject: reject)
        print("GET \(url.path) HTTP/1.1")
        request.allHTTPHeaderFields?.forEach { print("\($0): \($1)") }
        url.host.do { print("Host: \($0)") }
        task.resume()
        
        configure.pause = { [weak task] in task?.suspend() }
        configure.resume = { [weak task] in task?.resume() }
        configure.cancel = { [weak task] in task?.cancel() }
    }
}

public func cachedImage(forURL url: URL) -> UIImage? {
    let key = url.lastPathComponent
    return memoryCache[key]
}

public func fetchCachedImage(forURL url: URL) -> ImageTask {
    return Task { progress, fulfill, reject, configure in
        let key = url.lastPathComponent
        diskCache.get(key: key) { image in
            DispatchQueue.main.async {
                if let image = image {
                    fulfill(image)
                } else {
                    reject(.noData)
                }
            }
        }
    }
}

public func cacheImage(_ image: UIImage, forURL url: URL, toDisk: Bool) {
    let key = url.lastPathComponent
    memoryCache[key] = image
    if toDisk {
        diskCache.set(key: key, value: image)
    }
}

public extension ImageDisplaying {
    func setImageURL(_ url: URL, animated: Bool = false, success: @escaping (Self) -> Void = { _ in }) {
        let resource = ImageResource<DefaultSize>(url: url)
        setImageResource(resource, animated: animated, success: success)
    }
    
    func setImageURL<T: Size>(_ url: URL, size: T, animated: Bool = false, success: @escaping (Self) -> Void = { _ in }) {
        let resource = ImageResource(url: url, size: size)
        setImageResource(resource, animated: animated, success: success)
    }
}

public extension ImageDisplaying where Self: UIView {
    var size: CGSize {
        return bounds.size
    }
}

private extension ImageDisplaying {
    func setImageResource<T>(_ resource: ImageResource<T>, animated: Bool = false, success: @escaping (Self) -> Void) {
        if let existingTask = objc_getAssociatedObject(self, &imageTaskKey) as? ImageTask {
            existingTask.cancel()
        }
        
        let url = resource.url
        if let image = cachedImage(forURL: url) {
            setImage(image, update: true, animated: animated)
            success(self)
        } else {
            setImage(nil, update: true, animated: false)
            fetchCachedImage(forURL: url).success { image in
                DispatchQueue.main.async {
                    cacheImage(image, forURL: url, toDisk: false)
                    self.setImage(image, update: true, animated: animated)
                    success(self)
                }
            }.failure { _ in
                let task = request(resource)
                objc_setAssociatedObject(self, &imageTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                task.success {
                    cacheImage($0, forURL: url, toDisk: true)
                    self.setImage($0, update: true, animated: animated)
                    success(self)
                }
            }
        }
    }
}

extension UIImageView: ImageDisplaying {
    public func setImage(_ image: UIImage?, update: Bool, animated: Bool) {
        let setter = { self.image = image }
        if animated && self.image == nil {
            UIView.transition(with: self, duration: .animationDuration, options: [.transitionCrossDissolve, .allowUserInteraction], animations: setter, completion: nil)
        } else {
            setter()
        }
    }
}

private extension Int {
    static let cacheCapacity = 500
}

private extension TimeInterval {
    static let animationDuration = 0.3
}

private var imageTaskKey = "imageTask"

private let memoryCache = Cache<String, UIImage>(capacity: .cacheCapacity)

private let diskCache: DiskCache<UIImage> = {
    let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    return DiskCache<UIImage>(directory: documentsPath.path)!
}()
