//
//  GDTheme.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public protocol Theme {
    static var blue: UIColor { get }
    static var red: UIColor { get }
    static var text: UIColor { get }
    static var textGray: UIColor { get }
    static var textSubTitle: UIColor { get }
    static var textprompt: UIColor { get }

    static var tableViewBackground: UIColor { get }
    static var primary: UIColor { get }
    static var primaryDark: UIColor { get }
    static var secondary: UIColor { get }
    static var secondaryDark: UIColor { get }
    static var separator: UIColor { get }
    static var background: UIColor { get }
    static var statusBarStyle: UIStatusBarStyle { get }
    static var barStyle: UIBarStyle { get }
    static var keyboardAppearance: UIKeyboardAppearance { get }
    static var blurStyle: UIBlurEffect.Style { get }
}

struct GDTheme: Theme {
    static let blue = UIColor(hex: "#45AAFE")
    static let red = UIColor(hex: "#fc4747")
    static let tableViewBackground = UIColor(hex: "#fafbfc")
    static let primary = UIColor.white
    static let primaryDark = UIColor.white
    static var secondary = UIColor.red
    static var secondaryDark = UIColor.red
    static let separator = UIColor(hex: "#ececec")
    static let text = UIColor.black
    static let textGray = UIColor.gray
    static let lightGray = UIColor(hex: "#EFEFEF")
    static let background = UIColor(hex: "#ececec")
    static let statusBarStyle = UIStatusBarStyle.default
    static let barStyle = UIBarStyle.default
    static let keyboardAppearance = UIKeyboardAppearance.light
    static let blurStyle = UIBlurEffect.Style.extraLight
    static let textSubTitle = UIColor(hex: "#333333")
    static let textprompt = UIColor(hex: "#949ba1")
    static let orange = UIColor.orange

    static let smallIconSize = CGSize(width: 18, height: 18)
    static let barItemIconSize = CGSize(width: 25, height: 25)
}

public func GDFont(_ ofSize: CGFloat) -> UIFont {
    guard let font = UIFont(name: "PingFangSC-Regular", size: ofSize) else {
        return UIFont.systemFont(ofSize: ofSize)
    }
    return font
}

public func GDMFont(_ fontSize: CGFloat) -> UIFont {
    guard let font = UIFont(name: "PingFangSC-Medium", size: fontSize) else {
        return UIFont.systemFont(ofSize: fontSize, weight: .medium)
    }
    return font
}

