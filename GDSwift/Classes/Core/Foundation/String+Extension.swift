//
//  String+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

extension String {
    /// 生成 URL
    ///
    /// - Returns: URL:  baseURL 生成的 url
    /// - Throws: bathURL 或 path 不符合规则
    func asURL() throws -> URL? {

        guard !self.isEmpty else {
            return nil
        }

        var base = self
        if !base.hasPrefix("http:") || !base.hasPrefix("https:") {
            base = "http://".appending(base)
        }

        if let url = URL(string: base) {
            return url
        } else {
            return nil
        }
    }
    
    func trimHeadAndTailSpaces() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
