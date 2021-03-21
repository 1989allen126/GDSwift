//
//  UIViewController+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ObjectiveC
import UIKit

private func swizzle(_ vc: UIViewController.Type) {
    [
        (#selector(vc.viewDidLoad), #selector(vc.gd_viewDidLoad)),
        (#selector(vc.viewWillAppear(_:)), #selector(vc.gd_viewWillAppear(_:))),
        (#selector(vc.traitCollectionDidChange(_:)), #selector(vc.gd_traitCollectionDidChange(_:))),
        (#selector(vc.present(_:animated:completion:)),#selector(vc.presentB(_:animated:completion:)))
        ].forEach { original, swizzled in

            guard let originalMethod = class_getInstanceMethod(vc, original),
                let swizzledMethod = class_getInstanceMethod(vc, swizzled) else { return }

            let didAddViewDidLoadMethod = class_addMethod(vc,
                                                          original,
                                                          method_getImplementation(swizzledMethod),
                                                          method_getTypeEncoding(swizzledMethod))

            if didAddViewDidLoadMethod {
                class_replaceMethod(vc,
                                    swizzled,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
    }
}

extension UIViewController {

    open class func initClass() {
        guard self === UIViewController.self else { return }
        swizzle(self)
    }

    @objc internal func gd_viewDidLoad() {
        self.gd_viewDidLoad()
        self.configureUIElements()
        self.bindViewModel()
    }

    @objc internal func gd_viewWillAppear(_ animated: Bool) {
        self.gd_viewWillAppear(animated)

        DispatchQueue.once(token: self.gd_token) {
            self.bindStyles()
        }
    }
    
    @objc func presentB(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if #available(iOS 13.0, *) {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
            self.presentB(viewControllerToPresent, animated: animated, completion: completion)
        } else {
            self.presentB(viewControllerToPresent, animated: animated, completion: completion)
        }
    }

    @objc open func bindViewModel() {
        
    }
    
    @objc open func bindStyles() {
        
    }

    @objc open func configureUIElements() {
        
    }

    @objc public func gd_traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.gd_traitCollectionDidChange(previousTraitCollection)
        self.bindStyles()
    }

//    private struct AssociatedKeys {
//        static var hasViewAppeared = "hasViewAppeared"
//    }
//
//    // Helper to figure out if the `viewWillAppear` has been called yet
//    private var hasViewAppeared: Bool {
//        get {
//            return (objc_getAssociatedObject(self, &AssociatedKeys.hasViewAppeared) as? Bool) ?? false
//        }
//        set {
//            objc_setAssociatedObject(self,
//                                     &AssociatedKeys.hasViewAppeared,
//                                     newValue,
//                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
}

extension UIViewController {

    /// 取出当前控制器
    class var current:UIViewController? {
        
        var result:UIViewController? = nil
        let keyWindow = UIApplication.shared.keyWindow
        guard var window = keyWindow else {
            return result
        }
        
        if window.windowLevel != .normal {
            let windows = UIApplication.shared.windows
            for temp in windows {
                if temp.windowLevel == .normal {
                    window = temp
                    break
                }
            }
        }
        
        result = window.rootViewController
        while result?.presentedViewController != nil {
            result = result?.presentedViewController
        }
        
        if result != nil {
            /**取出当前控制器（UIViewController）*/
            repeat {
                if result!.isKind(of: UITabBarController.self),let rTabVC = result as? UITabBarController,rTabVC.selectedViewController != nil {
                    result = rTabVC.selectedViewController
                }
                
                if result!.isKind(of: UINavigationController.self),let navVC = result as? UINavigationController,navVC.visibleViewController != nil {
                    result = navVC.visibleViewController
                }
            } while (result != nil && (result!.isKind(of: UITabBarController.self) || result!.isKind(of: UINavigationController.self)))
        } else {
            return result
        }
        
        return result
    }
}
