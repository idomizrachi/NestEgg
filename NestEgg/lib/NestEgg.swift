//
//  NestEgg.swift
//  NestEgg
//
//  Created by Ido Mizrachi on 2/5/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

import Foundation
import UIKit.UIImage
import UIKit.UIImageView

public typealias NestEggImageCompletionBlock = (UIImage?, NSError?) -> ()
public typealias NestEggErrorCompletionBlock = (NSError?) -> ()


//MARK: Private class
private class ActiveRequestCallbacks: Equatable {
    var request: NestEggHttpRequest
    var callbacks: [(UIImage?, NSError?) -> ()]
    
    init(request: NestEggHttpRequest, callbacks: [NestEggImageCompletionBlock]) {
        self.request = request
        self.callbacks = callbacks
    }
    
    static func ==(lhs: ActiveRequestCallbacks, rhs: ActiveRequestCallbacks) -> Bool {
        return lhs.request.url == rhs.request.url
    }
}

//MARK: Public
@objc public class NestEgg: NSObject {
    private let httpClient: NestEggHttpClient
    private let cache: NestEggCache
    private var activeRequests: [ActiveRequestCallbacks] = []
    private let queue: DispatchQueue = DispatchQueue(label: "\(NestEgg.description()) queue")
    
    init(httpClient: NestEggHttpClient, cache: NestEggCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
    
    convenience init(httpClient: NestEggHttpClient) {
        let cache = NestEggDefaultCache(folder: String(describing: NestEgg.self))
        self.init(httpClient: httpClient, cache: cache)
    }
    
    
    public func fetch(url: String, completion: @escaping NestEggImageCompletionBlock) {
        self.queue.async { [weak self] in
            guard let strongSelf = self else {
                NestEgg.invokeCompletionBlock(image: nil, error: NestEgg.releasedError(), completion: completion)
                return
            }
            strongSelf.fetchInternal(url: url, completion: completion)
        }
    }
    
    private func fetchInternal(url: String, completion: @escaping NestEggImageCompletionBlock) {
        //Check if image exists in cache
        if let cachedImage = self.fetchFromCache(url: url) {
            NestEgg.invokeCompletionBlock(image: cachedImage, error: nil, completion: completion)
            return
        }
        //Download the image
        self.download(url: url, completion: completion)
    }
    
    public func fetch(url: String, imageView: UIImageView, completion: @escaping NestEggErrorCompletionBlock) {
        weak var weakImageView: UIImageView? = imageView
        fetch(url: url) { (image, error) in
            if error == nil {
                weakImageView?.image = image
            }
            completion(error)
        }
    }
    
    private static func invokeCompletionBlock(image: UIImage?, error: NSError?, completion: @escaping NestEggImageCompletionBlock) {
        DispatchQueue.main.async {
            completion(image, error)
        }
    }

    private func fetchFromCache(url: String) -> UIImage? {
        return self.cache.object(forKey: url)
    }
    
    private func hasActiveRequest(newRequest: NestEggHttpRequest) -> Bool {
        let activeRequest = self.activeRequest(newRequest: newRequest)
        return activeRequest != nil
    }
    
    private func activeRequest(newRequest: NestEggHttpRequest) -> ActiveRequestCallbacks? {
        let result = self.activeRequests.filter { (activeRequest) -> Bool in
            activeRequest.request.url == newRequest.url
        }
        if result.count > 0 {
            return result[0]
        } else {
            return nil
        }
    }
    
    private func download(url: String, completion: @escaping NestEggImageCompletionBlock) {
        let request: NestEggHttpRequest = NestEggHttpRequest(url: url)
        if let activeRequest = self.activeRequest(newRequest: request) {
            activeRequest.callbacks.append(completion)
        } else {
            let activeRequest: ActiveRequestCallbacks = ActiveRequestCallbacks(request: request, callbacks: [completion])
            self.activeRequests.append(activeRequest)
            self.httpClient.execute(request: request, response: { [weak self] (response) in
                guard let strongSelf = self else {
                    return
                }
                var image: UIImage? = nil
                var error: NSError? = response.error
                if error == nil, let data = response.data as Data?, let nsData = response.data {
                    if let nonNilImage = UIImage(data: data) {
                        image = nonNilImage
                        strongSelf.cache.setObject(data: nsData, matchingImage: nonNilImage, forKey: url)
                    } else {
                        error = NestEgg.notImageError()
                    }
                }
                let activeRequests = strongSelf.activeRequests.filter({ (activeRequest) -> Bool in
                    activeRequest.request.url == request.url
                })
                for activeRequest in activeRequests {
                    for callback in activeRequest.callbacks {
                        NestEgg.invokeCompletionBlock(image: image, error: error, completion: callback)
                    }
                }
                if let index = strongSelf.activeRequests.index(of: activeRequest) {
                    strongSelf.activeRequests.remove(at: index)
                }
            })
        }
    }
}
