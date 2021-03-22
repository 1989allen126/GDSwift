//
//  Then.swift
//  GDSwift
//
//  Created by apple on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
#if !os(Linux)
  import CoreGraphics
#endif
#if os(iOS) || os(tvOS)
  import UIKit.UIGeometry
#endif

public protocol GBThen {}

public extension GBThen where Self: Any {

  /// Makes it available to set properties with closures just after initializing and copying the value types.
  ///
  ///     let frame = CGRect().with {
  ///       $0.origin.x = 10
  ///       $0.size.width = 100
  ///     }
  @inlinable
  func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
    var copy = self
    try block(&copy)
    return copy
  }

  /// Makes it available to execute something with closures.
  ///
  ///     UserDefaults.standard.do {
  ///       $0.set("devxoul", forKey: "username")
  ///       $0.set("devxoul@gmail.com", forKey: "email")
  ///       $0.synchronize()
  ///     }
  @inlinable
  func `do`(_ block: (Self) throws -> Void) rethrows {
    try block(self)
  }

}

public extension GBThen where Self: AnyObject {

  /// Makes it available to set properties with closures just after initializing.
  ///
  ///     let label = UILabel().then {
  ///       $0.textAlignment = .center
  ///       $0.textColor = UIColor.black
  ///       $0.text = "Hello, World!"
  ///     }
  @inlinable
  func then(_ block: (Self) throws -> Void) rethrows -> Self {
    try block(self)
    return self
  }

}

extension NSObject: GBThen {}

#if !os(Linux)
  extension CGPoint: GBThen {}
  extension CGRect: GBThen {}
  extension CGSize: GBThen {}
  extension CGVector: GBThen {}
#endif

extension Array: GBThen {}
extension Dictionary: GBThen {}
extension Set: GBThen {}

#if os(iOS) || os(tvOS)
  extension UIEdgeInsets: GBThen {}
  extension UIOffset: GBThen {}
  extension UIRectEdge: GBThen {}
#endif
