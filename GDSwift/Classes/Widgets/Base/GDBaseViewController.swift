//
//  GDBaseViewController.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @discardableResult
    public func addFakeNavigationBar(title: String? = nil,
                              style: GDFakeNavigationBar.Style = .default,
                              backButtonAction action: (() -> Void)? = nil) -> GDFakeNavigationBar {
        let bar = GDFakeNavigationBar.bar(title: title, backAction: action, style: style)
        view.addSubview(bar)
        bar.snp.makeConstraints {
            $0.height.equalTo(barHeight())
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        return bar
    }

    func barHeight() -> CGFloat {
        struct Static {
            static var hasFringe: Bool?
        }

        if Static.hasFringe == nil {
            if #available(iOS 11.0, *) {
                if let keyWindow = UIApplication.shared.keyWindow {
                    Static.hasFringe = keyWindow.safeAreaInsets.bottom != 0
                } else {
                    Static.hasFringe = self.view.safeAreaInsets.bottom != 0
                }

            } else {
                Static.hasFringe = false
            }
        }

        return Static.hasFringe! ? CGFloat(88) : CGFloat(64)
    }
}

class GDBaseViewController: UIViewController {

    public let navigator = GDNavigator.default
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
