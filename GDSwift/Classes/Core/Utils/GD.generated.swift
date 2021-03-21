//
//  GD.generated.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.

import UIKit

public class GD {
    fileprivate class Class {}
    
    public static let hostingBundle = Bundle(for: GD.Class.self)
    
    static let IPhoneX = {
        return isIPhoneXSeries()
    }()
    
    static let ScreenWidth = UIScreen.main.bounds.width;
    static let ScreenHeight = UIScreen.main.bounds.height;
    
    ///状态栏高度
    static let StateBarHeight: CGFloat = {
        return UIApplication.shared.statusBarFrame.height
    }()

    ///导航栏高度
    static let NavBarRealHeight: CGFloat = 44.0

    ///标准Tabbar的高度
    static fileprivate let StantardTabbarH: CGFloat =  49.0

    ///NavigationBar 的高度
    static let NavigationBarHeight: CGFloat = {
        return (IPhoneX ? NavBarRealHeight * 2.0 : StateBarHeight + NavBarRealHeight)
    }()
    
    ///Tabbar的高度
    static let TabbarHeight: CGFloat = {
        return (IPhoneX ? (StantardTabbarH + safeAreaInsets.bottom) : StantardTabbarH)
    }()
    
    static var safeAreaInsets: UIEdgeInsets = {
        guard let window = UIApplication.shared.keyWindow else {
            return .zero
        }
        
        if #available(iOS 11.0, *) {
            return window.safeAreaInsets
        } else {
            // Fallback on earlier versions
            return .zero
        }
    }()
    
    class public func g(_ closure:@escaping () -> Void) {
        DispatchQueue.global().async {
            closure()
        }
    }

    class public func  m(_ closure:@escaping () -> Void) {
        let thread = Thread.current
        if thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: {
                closure()
            })
        }
    }

    class public func delayG(_ interval: TimeInterval, action:@escaping () -> Void) {
        let when = DispatchTime.now() + interval
        DispatchQueue.global().asyncAfter(deadline: when, execute: action)
    }

    class public func delayM(_ interval: TimeInterval, closure:@escaping () -> Void) {
        let when = DispatchTime.now() + interval
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    fileprivate static func isIPhoneXSeries() -> Bool {
        if (UIDevice.current.userInterfaceIdiom != .phone ) {
            return false
        }
        return (safeAreaInsets.bottom > 0);
    }
}
