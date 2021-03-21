//
//  UIColor+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public extension  UIColor {
    
    //返回随机颜色
    class  var randomColor: UIColor {
         get {
             let  red =  CGFloat(arc4random()%256)/255.0
             let  green =  CGFloat(arc4random()%256)/255.0
             let  blue =  CGFloat(arc4random()%256)/255.0
             return  UIColor(red: red, green: green, blue: blue, alpha: 1.0)
         }
    }
    
    /// 快速创建color
    /// - Parameters:
    ///   - string: 十六进制颜色
    ///   - alpha: 透明度
    convenience init(hex string: String, alpha: CGFloat = 1) {
        var hex = string.hasPrefix("#")
            ? String(string.dropFirst())
            : string
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: alpha)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }

        guard let intCode = Int(hex, radix: 16) else {
            self.init(white: 1.0, alpha: alpha)
            return
        }

        self.init(
            red: CGFloat((intCode >> 16) & 0xFF) / 255.0,
            green: CGFloat((intCode >> 8) & 0xFF) / 255.0,
            blue: CGFloat((intCode) & 0xFF) / 255.0, alpha: alpha)
    }
    
    // UIColor -> Hex String
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
         
        let multiplier = CGFloat(255.0)
         
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
         
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        } else {
#if DEBUG
            let str = String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier))
            
            Logger.debug("十六进制颜色：\(str),alpha:\(alpha)")
#endif
            
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
    
    var components:(r:CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
      var r: CGFloat = 0
      var g: CGFloat = 0
      var b: CGFloat = 0
      var a: CGFloat = 0
      getRed(&r, green: &g, blue: &b, alpha: &a)
      return (r, g, b, a)
    }
    
    var alphaComponent: CGFloat {
      return components.a
    }
    
    static var gd_seperator:UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.separator
        } else {
            // Fallback on earlier versions
            return UIColor(hex: "#3C3C43", alpha: 0.29)
        }
    }
}
