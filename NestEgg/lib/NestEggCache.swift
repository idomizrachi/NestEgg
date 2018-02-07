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
    func setObject(image: UIImage, forKey key: String)
    func setObject(data: NSData, forKey key: String)
    func removeObject(forKey key: String)
    func clear()
}

//MARK: Implementation
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
    
    convenience init(folder: String) {
        self.init(folder: folder, timeoutInterval: 60 * 60 * 24)
    }
    
    init(folder: String, timeoutInterval: TimeInterval) {
        self.folder = folder
        self.timeoutInterval = timeoutInterval
        self.memoryCache = NSCache<NSString, NestEggCacheItem>()
    }
    
    public func object(forKey key: String) -> UIImage? {
        let md5Key: String = key.md5()
        return self.internalObject(forKey: md5Key)
    }
    
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
        print("fetched from memory")
        return cachedItem.image
    }
    
    private func diskCachedImage(forKey key: String) -> UIImage? {
        var image: UIImage? = nil
        let path = savePath(key: key)
        if FileManager.default.fileExists(atPath: path) {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                if let creationDate = attributes[.creationDate] as? Date {
                    if isValid(date: creationDate) == false {
                        try FileManager.default.removeItem(atPath: path)
                    } else {
                        image = UIImage(contentsOfFile: path)
                        if let nonNilImage = image {
                            let cachedItem: NestEggCacheItem = NestEggCacheItem(image: nonNilImage, creationDate: creationDate)
                            print("adding to from disk to memory")
                            self.memoryCache.setObject(cachedItem, forKey: key as NSString)
                        }
                    }
                }
            } catch {
                print("\(error)")
            }
        }
        if image != nil {
            print("fetched from disk")
        }
        return image
    }
    
    public func setObject(image: UIImage, forKey key: String) {
        let md5Key: String = key.md5()
        guard let data = UIImagePNGRepresentation(image) as NSData? else {
            return
        }
        internalSetObject(data: data, image: image, key: md5Key)
    }
    
    public func setObject(data: NSData, forKey key: String) {
        let md5Key: String = key.md5()
        guard let image = UIImage(data: data as Data) else {
            return
        }
        internalSetObject(data: data, image: image, key: md5Key)
    }
    
    private func internalSetObject(data: NSData, image: UIImage, key: String) {
        let cachedItem: NestEggCacheItem = NestEggCacheItem(image: image)
        print("adding to memory")
        self.memoryCache.setObject(cachedItem, forKey: key as NSString)
        print("adding to disk")
        save(data: data, forKey: key)
    }
    
    public func save(data: NSData, forKey key: String) {        
        let path = savePath(key: key)
        do {
            let onlyPath = "\(NSTemporaryDirectory())\(self.folder)"
            let isDirectory: UnsafeMutablePointer<ObjCBool>? = nil
            if FileManager.default.fileExists(atPath: onlyPath, isDirectory: isDirectory) == false {
                do {
                    try FileManager.default.createDirectory(atPath: onlyPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("\(error)")
                }                    
            }
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            print("\(error)")
        }
    }
    
    private func savePath(key: String) -> String {
        var path = NSTemporaryDirectory()
        path.append("\(self.folder)/\(key)")
        return path
    }
    
    
    public func removeObject(forKey key: String) {
        let md5Key = key.md5()
        internalRemoveObject(forKey: md5Key)
    }
    
    public func internalRemoveObject(forKey key: String) {
        self.memoryCache.removeObject(forKey: key as NSString)
        var path = NSTemporaryDirectory()
        path.append("/" + key)
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("\(error)")
        }
    }
    
    public func clear() {
        self.memoryCache.removeAllObjects()
        let path = NSTemporaryDirectory() + "/" + self.folder
        let enumerator = FileManager.default.enumerator(atPath: path)
        while let file = enumerator?.nextObject() {
            print(file)
        }
    }
    
    private func isValid(date: Date) -> Bool {
        let difference = Date().timeIntervalSince(date)
        print("difference \(difference)")
        return difference < self.timeoutInterval
    }
    
}

extension String {
    public func md5() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let d = self.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
}
