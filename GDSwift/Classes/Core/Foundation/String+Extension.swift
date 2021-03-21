//
//  String+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

/// Types adopting the `URLConvertible` protocol can be used to construct `URL`s, which can then be used to construct
/// `URLRequests`.
public protocol URLConvertible {
    /// Returns a `URL` from the conforming instance or throws.
    ///
    /// - Returns: The `URL` created from the instance.
    /// - Throws:  Any error thrown while creating the `URL`.
    func asURL() throws -> URL
}

public extension String {
    
    /// 返回string的长度
    var length:Int{
        get {
            return self.count;
        }
    }
    
    /// 截取字符串从开始到 index
    func substring(to index: Int) -> String {
        guard let end_Index = validEndIndex(original: index) else {
            return self;
        }

        return String(self[startIndex..<end_Index]);
    }
    
    /// 截取字符串从index到结束
    func substring(from index: Int) -> String {
        guard let start_index = validStartIndex(original: index)  else {
            return self
        }
        
        return String(self[start_index..<endIndex])
    }
    
    
    /// 返回子串的位置，未找到返回NSNotFound
    /// - Parameter substring: 查找子串
    /// - Returns: location（未找到-1）
    func rangeOf(_ substring:String) -> Int {
        
        guard let range: Range = self.range(of: substring) else {
            return -1
        }
        
        return self.distance(from: self.startIndex, to:range.lowerBound)
    }
    
    /// 切割字符串(区间范围 前闭后开)
    func sliceString(_ range:CountableRange<Int>)->String {

        guard
            let startIndex = validStartIndex(original: range.lowerBound),
            let endIndex   = validEndIndex(original: range.upperBound),
            startIndex <= endIndex
            else {
                return ""
        }

        return String(self[startIndex..<endIndex])
    }
    
    /// 切割字符串(区间范围 前闭后闭)
    func sliceString(_ range:CountableClosedRange<Int>) -> String {

        guard
            let start_Index = validStartIndex(original: range.lowerBound),
            let end_Index   = validEndIndex(original: range.upperBound),
            startIndex <= endIndex
            else {
                return ""
        }
        
        if(endIndex.utf16Offset(in: self) <= end_Index.utf16Offset(in: self)){
            return String(self[start_Index..<endIndex])
        }
        
        return String(self[start_Index...end_Index])
    }
    
    /// 校验字符串位置 是否合理，并返回String.Index
    private func validIndex(original: Int) -> String.Index {
        
        switch original {
        case ...startIndex.utf16Offset(in: self) : return startIndex
        case endIndex.utf16Offset(in: self)...   : return endIndex
        default                          : return index(startIndex, offsetBy: original)
        }
    }
    
    /// 校验是否是合法的起始位置
    private func validStartIndex(original: Int) -> String.Index? {
        guard original <= endIndex.utf16Offset(in: self) else { return nil }
        return validIndex(original:original)
    }
     
    /// 校验是否是合法的结束位置
    private func validEndIndex(original: Int) -> String.Index? {
        guard original >= startIndex.utf16Offset(in: self) else { return nil }
        return validIndex(original:original)
    }
}

public extension String {
    
    func trimHeadAndTailSpaces() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    /// 字符串转bool值
    var boolValue: Bool {
        //两种实现都可以
        return ["true", "y", "t", "yes", "1"].contains { self.caseInsensitiveCompare($0) == .orderedSame }
        
//        switch self.lowercased() {
//        case "true", "t", "yes", "y", "1":
//            return true
//        case "false", "f", "no", "n", "0":
//            return false
//        default:
//            return false
//        }
    }
    
    
    /// url编码
    /// - Returns: 编码后的url
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters:
                                            .urlQueryAllowed) ?? ""
    }
     
    /// url解码
    /// - Returns: l解码后的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
    
    /// 从String中截取出参数
    var urlComponents: [String: Any]? {
        
        // 判断是否有参数
        let start = self.rangeOf("?")
        guard  start >= 0 else {
            return nil
        }

        var params = [String: Any]()
        // 截取参数
        let paramsString = self.substring(from: start + 1)
        guard !isEmptyString(content: paramsString) else {
            return nil
        }

        // 判断参数是单个参数还是多个参数
        if paramsString.contains("&") {

            // 多个参数，分割参数
            let urlComponents = paramsString.components(separatedBy: "&")
            
            // 遍历参数
            for keyValuePair in urlComponents {
                // 生成Key/Value
                let pairComponents = keyValuePair.components(separatedBy: "=")
                let key = pairComponents.first?.removingPercentEncoding
                let value = pairComponents.last?.removingPercentEncoding
                // 判断参数是否是数组
                if let key = key, let value = value {
                    // 已存在的值，生成数组
                    if let existValue = params[key] {
                        if var existValue = existValue as? [Any] {
                            existValue.append(value)
                        } else {
                            params[key] = [existValue, value] as AnyObject
                        }
                    } else {
                        params[key] = value as AnyObject
                    }
                }
            }
        } else {

            // 单个参数
            let pairComponents = paramsString.components(separatedBy: "=")

            // 判断是否有值
            if pairComponents.count == 1 {
                return nil
            }
            
            let key = pairComponents.first?.removingPercentEncoding
            let value = pairComponents.last?.removingPercentEncoding
            if let key = key,let value = value {
                params[key] = value
            }
        }
        return params
    }
}


extension String:URLConvertible {

    /// Returns a `URL` if `self` can be used to initialize a `URL` instance, otherwise throws.
    ///
    /// - Returns: The `URL` initialized with `self`.
    /// - Throws:  An `AFError.invalidURL` instance.
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw NSError.init(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"invalidURL"])  }

        return url
    }
}

extension URL: URLConvertible {
    /// Returns `self`.
    public func asURL() throws -> URL { self }
}

extension URLComponents: URLConvertible {
    /// Returns a `URL` if the `self`'s `url` is not nil, otherwise throws.
    ///
    /// - Returns: The `URL` from the `url` property.
    /// - Throws:  An `AFError.invalidURL` instance.
    public func asURL() throws -> URL {
        guard let url = url else { throw NSError.init(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey:"invalidURL"]) }

        return url
    }
}
