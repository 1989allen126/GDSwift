//
//  UIImage+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 根据颜色创建图片
    /// - Parameter color: 颜色
    /// - Returns: 图片
    class func GDCreateImageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    /// 截图
    /// - Parameter view: 子控件
    /// - Returns: 图片
    class func GDCreateImageWithView(view: UIView) -> UIImage? {
        let size = view.bounds.size;
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数。
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 改变图片尺寸
    /// - Parameter newSize: 尺寸
    /// - Returns: image
    func GDReSize(to newSize: CGSize) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
      draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
      let result = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return result ?? self
    }
}
