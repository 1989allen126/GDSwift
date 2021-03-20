//
//  GDEnvConfig.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public class GDEnvConfig: NSObject {
    @objc public static let defaultConfig = GDEnvConfig()
    @objc public var languageCode:String? = nil
}
