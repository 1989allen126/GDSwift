//
//  GDLanguageLocalize.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public  func  GDLocalizedString(key:String) -> String {
    guard let value = Bundle.gd_localized(key) else {
        return ""
    }
    
    return value
}

public extension Bundle {
    
    class var hostingBundle: Bundle {
        struct Static {
            static let __bundle: Bundle = GD.hostingBundle
        }

        return Static.__bundle
    }
    
    static func gd_localized(_ key:String,value:String? = nil) -> String? {
        var bundle:Bundle? = nil
    
        if bundle == nil {
            var language:String = "en"
            if let languageCode = GDEnvConfig.defaultConfig.languageCode {
                language = languageCode
            } else {
                language = NSLocale.preferredLanguages.first ?? "en"
            }
            
            if language.hasPrefix("en") {
                language = "en"
            } else if language.hasPrefix("zh") {
                language = "zh-Hans"
            } else {
                language = "en"
            }
            
            if let path = Bundle.hostingBundle.path(forResource: language, ofType: "lproj") {
                bundle = Bundle(path: path)
            }
        }
        
        guard let sourceBundle = bundle else {
            return value
        }

        let sourceValue = sourceBundle.localizedString(forKey: key, value: value,table: nil)
        return Bundle.main.localizedString(forKey: key, value: sourceValue, table: nil)
    }
}
