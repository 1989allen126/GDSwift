//
//  UIApplication+Extension.swift
//  GDSwift
//
//  Created by apple on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

extension UIApplication {
    
    var preferredApplicationWindow: UIWindow? {
        if let appWindow = UIApplication.shared.delegate?.window, let window = appWindow {
            return window
        } else if let window = UIApplication.shared.keyWindow {
            return window
        }

        return nil
    }
}
