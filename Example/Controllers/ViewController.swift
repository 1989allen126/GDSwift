//
//  ViewController.swift
//  GDSwift
//
//  Created by apple on 03/17/2021.
//  Copyright (c) 2021 apple. All rights reserved.
//

import UIKit
import GDSwift.Swift

class ViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
}

// MARK:- 初始化UI
extension ViewController {
    fileprivate func initUI() {
        self.view.backgroundColor = UIColor.gray
        
        let str:String =  "https://www.baidu.com?a=121321&b=1231321&c=fasfaf####&a=&basdaf=121"
//        guard let url = URL(string: str) else {
//            return
//        }
//
//        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
//                let queryItems = components.queryItems else {
//            return
//        }
//
//        let param = queryItems.reduce(into: [String: String]()) { (result, item) in
//            result[item.name] = item.value
//        }
        
        Logger.debug("====\(str.urlComponents)======")
    }
}

