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
    
    @objc static let gdBundle: Bundle  = GD.hostingBundle
    
    @objc class var gdResourceBundle: Bundle {
        struct Static {
            static let _gdResourceBundle: Bundle = {
                var sourceBundle = Bundle.gdBundle
                let bundleURL = sourceBundle.url(forResource: "GDBundleResource", withExtension: "bundle")
                return bundleURL.flatMap(Bundle.init(url:)) ?? sourceBundle
            }()
        }
        return Static._gdResourceBundle
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
            
            if let path = Bundle.gdResourceBundle.path(forResource: language, ofType: "lproj") {
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

public extension UIImage {
    
    convenience init?(gd_named: String,path:String? = "image") {
        guard !gd_named.isEmpty else {
            self.init()
            return
        }
        
        var finalImageName:String = gd_named
        if let imagePath = path,!imagePath.isEmpty {
            finalImageName = "\(imagePath)/\(finalImageName)"
        }
        
        guard let fullImagePath = Bundle.gdResourceBundle.resourcePath?.appending("/\(finalImageName)") else {
            self.init(named: gd_named, in: Bundle.gdResourceBundle, compatibleWith: nil)
            return
        }
        
        self.init(contentsOfFile: fullImagePath)
    }
    
    static func gdImageNamed(named: String,path:String? = "image") -> UIImage? {
        return UIImage(gd_named: named,path: path)
    }
}
