//
//  NestEggCache.swift
//  NestEgg
//
//  Created by Ido Mizrachi on 2/6/18.
//  Copyright © 2018 Ido Mizrachi. All rights reserved.
//

import Foundation
import UIKit.UIImage

//MARK: Protocol
@objc public protocol NestEggCache {
    func object(forKey key: String) -> UIImage?
    func setObject(data: NSData, matchingImage: UIImage, forKey key: String)
//    func setObject(data: NSData, forKey key: String)
    func removeObject(forKey key: String)
    func clear()
}

//MARK: Default Implementation
class NestEggCacheItem {
    var image:UIImage
    var creationDate: Date
    
    convenience init(image: UIImage) {
        self.init(image: image, creationDate: Date())
    }
    
    init(image: UIImage, creationDate: Date) {
        self.image = image
        self.creationDate = creationDate
    }
}


@objc public class NestEggDefaultCache: NSObject, NestEggCache {
    private let folder: String
    private let timeoutInterval: TimeInterval
    private let memoryCache: NSCache<NSString, NestEggCacheItem>
    private let diskCacheQueue: DispatchQueue
    
    convenience init(folder: String) {
        self.init(folder: folder, timeoutInterval: 60 * 60 * 24)
    }
    
    init(folder: String, timeoutInterval: TimeInterval) {
        self.folder = folder
        self.timeoutInterval = timeoutInterval
        self.memoryCache = NSCache<NSString, NestEggCacheItem>()
        self.diskCacheQueue = DispatchQueue(label: "disk-cache-queue")
    }
    
    //MARK: Public
    public func object(forKey key: String) -> UIImage? {
        let md5Key: String = key.md5()
        return self.internalObject(forKey: md5Key)
    }
    
    public func setObject(data: NSData, matchingImage: UIImage, forKey key: String) {
        let md5Key: String = key.md5()
        return internalSetObject(data: data, image: matchingImage, key: md5Key)
    }
    
    public func removeObject(forKey key: String) {
        let md5Key = key.md5()
        internalRemoveObject(forKey: md5Key)
    }

    public func clear() {
        self.memoryCache.removeAllObjects()
        let path = self.cacheFullPath()
        let enumerator = FileManager.default.enumerator(atPath: path)
        self.diskCacheQueue.sync {
            while let file = enumerator?.nextObject() {
                let fullPath = "\(path)/\(file)"
                do {
                    try FileManager.default.removeItem(atPath: fullPath)
                } catch {
                }
            }
        }
    }
    
    
    //MARK: Private
    private func internalObject(forKey key: String) -> UIImage? {
        var image:UIImage? = nil
        image = self.memoryCachedImage(forKey: key)
        if image == nil {
            image = self.diskCachedImage(forKey: key)
        }
        return image
    }
    
    private func memoryCachedImage(forKey key: String) -> UIImage? {
        guard let cachedItem: NestEggCacheItem = self.memoryCache.object(forKey: key as NSString) else {
            return nil
        }
        if isValid(date: cachedItem.creationDate) == false {
            self.memoryCache.removeObject(forKey: key as NSString)
            return nil
        }
        return cachedItem.image
    }
    
    private func diskCachedImage(forKey key: String) -> UIImage? {
        var image: UIImage? = nil
        let path = savePath(key: key)
        if FileManager.default.fileExists(atPath: path) == false {
            return nil
        }
        self.diskCacheQueue.sync {
            if FileManager.default.fileExists(atPath: path) == false {
                return
            }
            let attributes: [FileAttributeKey: Any]?
            do {
                attributes = try FileManager.default.attributesOfItem(atPath: path)

            } catch {
                attributes = nil
            }
            guard let nonNilAttributes = attributes else {
                return
            }
            guard let creationDate = nonNilAttributes[.creationDate] as? Date else {
                return
            }
            if isValid(date: creationDate) == false {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                }
            } else {
                image = UIImage(contentsOfFile: path)
                if let nonNilImage = image {
                    let cachedItem: NestEggCacheItem = NestEggCacheItem(image: nonNilImage, creationDate: creationDate)
                    self.memoryCache.setObject(cachedItem, forKey: key as NSString)
                } 
            }
        }
        return image
    }
    
    private func internalSetObject(data: NSData, image: UIImage, key: String) {
        let cachedItem: NestEggCacheItem = NestEggCacheItem(image: image)
        if (self.memoryCache.object(forKey: key as NSString)) != nil {
            self.memoryCache.removeObject(forKey: key as NSString)
        }
        self.memoryCache.setObject(cachedItem, forKey: key as NSString)
        save(data: data, forKey: key)
    }
    
    private func cacheFullPath() -> String {
        var cacheFullPath = NSTemporaryDirectory()
        cacheFullPath.append(self.folder)
        return cacheFullPath
    }
    
    private func savePath(key: String) -> String {
        var path = self.cacheFullPath()
        path.append("/\(key)")
        return path
    }
    
    private func save(data: NSData, forKey key: String) {
        let path = savePath(key: key)
        do {
            let onlyPath = "\(NSTemporaryDirectory())\(self.folder)"
            let isDirectory: UnsafeMutablePointer<ObjCBool>? = nil
            if FileManager.default.fileExists(atPath: onlyPath, isDirectory: isDirectory) == false {
                do {
                    try FileManager.default.createDirectory(atPath: onlyPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                }
            }
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
        }
    }
    
    public func internalRemoveObject(forKey key: String) {
        self.memoryCache.removeObject(forKey: key as NSString)
        var path = NSTemporaryDirectory()
        path.append("/" + key)
        self.diskCacheQueue.sync {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
            }
        }        
    }
    
    private func isValid(date: Date) -> Bool {
        let difference = Date().timeIntervalSince(date)
        return difference < self.timeoutInterval
    }
}

