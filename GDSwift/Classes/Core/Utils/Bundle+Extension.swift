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
                var bundle = GD.hostingBundle
                if let path = bundle.path(forResource: "GDSwiftResourceBundle.bundle", ofType: nil), let resourcesBundle = Bundle(path: path) {
                    return resourcesBundle
                }

                if let resourceBundleUrl = bundle.url(forResource: "GDBundleResource", withExtension: "bundle"), let resourcesBundle = Bundle(url: resourceBundleUrl) {
                    return resourcesBundle
                }
                return bundle
            }()
        }

        return Static._gdResourceBundle
    }
}

extension UIImage {
    
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
    
    public static func gdImageNamed(named: String,path:String? = "image") -> UIImage? {
        return UIImage(gd_named: named,path: path)
    }
}
