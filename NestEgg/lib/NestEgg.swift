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


@objc public class NestEgg: NSObject {
    private let httpClient: NestEggHttpClient
    private let cache: NestEggCache
    private var activeRequests: [NestEggHttpRequest] = []
    
    init(httpClient: NestEggHttpClient, cache: NestEggCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
    
    convenience init(httpClient: NestEggHttpClient) {
        self.init(httpClient: httpClient, cache: NestEggDefaultCache(folder: String(describing: NestEgg.self)))
    }
    
    
    public func fetch(url: String, completion: @escaping (UIImage?, NSError?) -> ()) {
        
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else {
                NestEgg.invokeCompletionBlock(image: nil, error: NestEgg.releasedError(), completion: completion)
                return
            }
            //Check if image exists in cache
            if let cachedImage = strongSelf.fetchFromCache(url: url) {
                print("image is cached \(url)")
                NestEgg.invokeCompletionBlock(image: cachedImage, error: nil, completion: completion)
                return
            }            
            //Download the image
            let request: NestEggHttpRequest = NestEggHttpRequest(url: url)
            self?.activeRequests.append(request)
            print("sending request to \(url)")
            strongSelf.httpClient.execute(request: request, response: { [weak self] (response) in
                guard let strongSelf = self else {
                    return
                }
                if let index = strongSelf.activeRequests.index(of: request) {
                    print("Removing request: \(request)")
                    strongSelf.activeRequests.remove(at: index)
                }
                var image: UIImage? = nil
                var error: NSError? = response.error
                if error == nil, let data = response.data as Data? {
                    image = UIImage(data: data)
                    print("set object to cache")
                    strongSelf.cache.setObject(data: response.data!, forKey: url)
                    if image == nil {
                        error = NestEgg.notImageError()
                    }
                }
                print("response error \(String(describing: error))")
                NestEgg.invokeCompletionBlock(image: image, error: error, completion: completion)
            })
        }
    }
    
    private static func invokeCompletionBlock(image: UIImage?, error: NSError?, completion: @escaping (UIImage?, NSError?) -> ()) {
        DispatchQueue.main.async {
            completion(image, error)
        }
    }
    
    public func fetch(url: String, imageView: UIImageView, completion: @escaping(NSError?) -> ()) {
        fetch(url: url) { (image, error) in
            if error == nil {
                imageView.image = image
            }
            completion(error)
        }
    }

    private func fetchFromCache(url: String) -> UIImage? {
        return self.cache.object(forKey: url)
    }
    
    
    
}
