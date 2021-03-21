//
//  GDCacheable.swift
//  GDSwift
//
//  Created by apple on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public protocol GDCacheable {}
public protocol GDObjectCacheable: GDCacheable {
    func objectForKey(_ key: String) -> AnyObject?
    func setObject(_ obj: AnyObject, forKey key: String)
    func setNSObject(_ obj: NSObject, forKey key: String)
    func removeObjectForKey(_ key: String)
    func removeAllObjects()
}
