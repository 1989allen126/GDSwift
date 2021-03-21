//
//  GDCache.swift
//  GDSwift
//
//  Created by apple on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

open class GDCache {
    
    ///  单例
    public class var sharedCache: GDCache {
        struct Static {
            static let __cache: GDCache = GDCache()
        }
        return Static.__cache
    }
    
    open var objectCache: GDCacheable

    init() {
        self.objectCache = GDDefaultObjectCache()
    }
    
    /// 获取存储对象
    /// - Parameter key: 键值
    /// - Returns: 存储对象
    public func objectForKey(_ key: String) -> AnyObject? {
        guard let cache = objectCache as? GDDefaultObjectCache else {
            return nil
        }
        return cache.objectForKey(key)
    }
    
    /// 设置存储对象
    /// - Parameter obj: 键值
    /// - Parameter key: 值
    public func setAnyObject(_ obj: AnyObject, forKey key: String) {
        
        guard let cache = objectCache as? GDDefaultObjectCache else {
            return
        }
        cache.setObject(obj, forKey: key)
    }
    
    public func setObject(_ obj: Any, forKey key: String) {
        guard let cache = objectCache as? GDDefaultObjectCache ,let value = obj as? NSObject else {
            return
        }
        cache.setNSObject(value, forKey: key)
    }
    
    /// 移除存储对象
    /// - Parameter key: 值
    public func removeObjectForKey(_ key: String) {
        guard let cache = objectCache as? GDDefaultObjectCache else {
            return
        }
        
        cache.removeObjectForKey(key)
    }
    
    /// 移除所有存储对象
    public func removeAllObjects() {
        
        guard let cache = objectCache as? GDDefaultObjectCache else {
            return
        }
        
        cache.removeAllObjects()
    }
}

class GDDefaultObjectCache: GDObjectCacheable {
    var cache: NSCache<AnyObject, AnyObject>

    init() {
        cache = NSCache()
    }
    
    func objectForKey(_ key: String) -> AnyObject? {
        return cache.object(forKey: key as AnyObject) as? NSObject
    }
    
    func setObject(_ obj: AnyObject, forKey key: String) {
        cache.setObject(obj, forKey: key as AnyObject)
    }
    
    func setNSObject(_ obj: NSObject, forKey key: String) {
        cache.setObject(obj, forKey: key as AnyObject)
    }
    
    func removeObjectForKey(_ key: String) {
        cache.removeObject(forKey: key as AnyObject)
    }
    
    func removeAllObjects() {
        cache.removeAllObjects()
    }
}

