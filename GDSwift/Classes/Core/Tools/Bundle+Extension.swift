//
//  Bundle+Extension.swift
//  GDSwift
//
//  Created by apple on 2021/3/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

extension Bundle {

    @objc public class var gdResourceBundle: Bundle {
        struct Static {
            static let _gdResourceBundle: Bundle = {
                var bundle = Gd.hostingBundle
                if let path = bundle.path(forResource: "GdBundleResource.bundle", ofType: nil), let resourcesBundle = Bundle(path: path) {
                    return resourcesBundle
                }

                if let resourceBundleUrl = bundle.url(forResource: "GdBundleResource", withExtension: "bundle"), let resourcesBundle = Bundle(url: resourceBundleUrl) {
                    return resourcesBundle
                }
                return bundle
            }()
        }

        return Static._gdResourceBundle
    }
}

extension UIImage {
    
    public static func gdImageNamed(named: String) -> UIImage? {
        guard !named.isEmpty else {
            return nil
        }
        
        if let fullImagePath = Bundle.gdResourceBundle.resourcePath?.appending("/\(named)") {
            return UIImage(contentsOfFile: fullImagePath)
        }
        
        return UIImage(named: named, in: Bundle.gdResourceBundle, compatibleWith: nil)
    }
}
