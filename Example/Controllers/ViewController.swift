//
//  ViewController.swift
//  GDSwift
//
//  Created by apple on 03/17/2021.
//  Copyright (c) 2021 apple. All rights reserved.
//

import UIKit
import GDSwift

class ViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
}

// MARK:- 初始化UI
extension ViewController {
    fileprivate func initUI() {
        GDEnvConfig.defaultConfig.languageCode = "zh-Hans"
        let str = Bundle.gd_localized("App.displayName")
        LXFLog("=========\(String(describing: str))", type: .debug)
    }
}

