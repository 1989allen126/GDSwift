//
//  Array+Extension.swift
//  GDSwift
//
//  Created by apple on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

public extension Array where Element == String {
    func joinedWithAmpersands() -> String {
        joined(separator: "&")
    }
}
