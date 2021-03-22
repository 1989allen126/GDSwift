//
//  GDCommonTools.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

/// 检测相机权限
public func gdcheckCameraAuthStatus() -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    switch status {
    case .authorized, .notDetermined:
        return true
    default:
        return false
    }
}

/// 检测相机权限
/// - Parameter handle: 完成回调
public func gdcheckCameraAuthStatusEx(_ handle: ((Bool) -> Void)? = nil) {
    DispatchQueue.main.async {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .notDetermined:
            // 第一次触发授权 alert
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                DispatchQueue.main.async {
                    handle?(granted)
                }
            })
        case .authorized:
            handle?(true)
        default:
            handle?(false)
        }
    }
}

/// 快速打开url
/// - Parameter content: 需要跳转的url
public func GDOpenURL(url:URL) {
    if UIApplication.shared.canOpenURL(url) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

/// 打开系统设置页面
public func GDOpenURLSetting() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
        return
    }
    GDOpenURL(url:url)
}

/// 判断字符串是否为空
/// - Parameter content: 字符串内容
/// - Returns: true/false
public func isEmptyString(content: String?) -> Bool {
    guard let content = content, !content.isEmpty else {
        return true
    }

    return false
}

/// 如果是空字符串，返回ify（默认为空）
/// - Parameters:
///   - content: 字符串内容
///   - ify: placeholder
/// - Returns: 结果
public func emptyString(content: String?, ify: String = "") -> String {
    guard let content = content, !content.isEmpty else {
        return ify
     }

    return content
}

//验证手机号
public func isTelNumber(num:String)->Bool {
    
    let mobile = "^1(7[0-9]|3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
    let  CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
    let  CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
    let  CT = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
    let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
    let regextestcm = NSPredicate(format: "SELF MATCHES %@",CM )
    let regextestcu = NSPredicate(format: "SELF MATCHES %@" ,CU)
    let regextestct = NSPredicate(format: "SELF MATCHES %@" ,CT)
    if ((regextestmobile.evaluate(with: num) == true)
            || (regextestcm.evaluate(with: num)  == true)
            || (regextestct.evaluate(with: num) == true)
            || (regextestcu.evaluate(with: num) == true)){
        return true
    } else {
        return false
    }
}

/// 判断是否为数字
/// - Parameter num: 字符串
/// - Returns: true/false
public func isNumber(num: String) -> Bool {
   let scan: Scanner = Scanner(string: num)
   var val:Int = 0
   return scan.scanInt(&val) && scan.isAtEnd
}

/// 正则匹配
///
/// - Parameters:
///   - regex: 匹配规则
///   - validateString: 匹配对test象
/// - Returns: 返回结果
public func regularExpression (regex: String, validateString: String) -> [String] {
    do {
        let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
        let matches = regex.matches(in: validateString, options: [], range: NSRange(location: 0, length: validateString.count))

        var data: [String] = Array()
        for item in matches {
            let string = (validateString as NSString).substring(with: item.range)
            data.append(string)
        }

        return data
    } catch {
        return []
    }
}

/// 字符串的替换
///
/// - Parameters:
///   - validateString: 匹配对象
///   - regex: 匹配规则
///   - content: 替换内容
/// - Returns: 结果
public func replace(validateString: String, regex: String, content: String) -> String {
    do {
        let RE = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
        let modified = RE.stringByReplacingMatches(in: validateString, options: .reportProgress, range: NSRange(location: 0, length: validateString.count), withTemplate: content)
        return modified
    } catch {
        return validateString
    }
}

public extension NSObject {
    var gd_token:String {
        return String(format: "gd_%@_%x",NSStringFromClass(Self.self),self.hash)
    }
}

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
     class func once(token: String, handle:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        handle()
    }
    
    /// Execute the provided closure after a `TimeInterval`.
    ///
    /// - Parameters:
    ///   - delay:   `TimeInterval` to delay execution.
    ///   - closure: Closure to execute.
    func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }
}
