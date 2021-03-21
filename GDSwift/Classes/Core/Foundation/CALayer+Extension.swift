//
//  CALayer+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension CALayer {
    func addShadow(shadowColor: UIColor, shadowOpacity: CGFloat, shadowRadius: CGFloat, shadowOffset: CGSize) {
        self.shadowColor = shadowColor.cgColor
        self.shadowOffset = shadowOffset
        self.shadowRadius = shadowRadius
        self.shadowOpacity = Float(shadowOpacity)
    }
}
