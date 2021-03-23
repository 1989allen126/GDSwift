//
//  UIView+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

public extension UIView {
    
    // MARK: - Create your borders and assign them to a property on a view when you can via the create methods when possible. Otherwise you might end up with multiple borders being created.
    enum BorderSide {
        case left, top, right, bottom
    }

    func defaultBorderColor() -> UIColor {
        return UIColor.gd_seperator
    }

    func defaultBorderDepth() -> CGFloat {
        return 0.5
    }

    /// Add Border for side with default params
    ///
    /// - Parameter side: Border Side
    /// - Returns: Border view
    @discardableResult
    func addBorder(for side: BorderSide) -> UIView {
        return addBorder(for: side, color: defaultBorderColor(), depth: defaultBorderDepth())
    }

    /// Add Bottom Border with default params
    ///
    /// - Parameters:
    ///   - leftInset: left inset
    ///   - rightInset: right inset
    /// - Returns: Border view
    @discardableResult
    func addBottomBorder(leftInset: CGFloat = 10, rightInset: CGFloat = 0) -> UIView {
        let border = UIView()
        border.backgroundColor = defaultBorderColor()
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(leftInset)
            make.right.equalToSuperview().inset(rightInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(self.defaultBorderDepth())
        }
        return border
    }

    /// Add Top Border for side with color, depth, length and offsets
    ///
    /// - Parameters:
    ///   - side: Border Side
    ///   - color: Border Color
    ///   - depth: Border Depth
    ///   - length: Border Length
    ///   - inset: Border Inset
    ///   - cornersInset: Border Corners Inset
    /// - Returns: Border view
    @discardableResult
    func addBorder(for side: BorderSide, color: UIColor, depth: CGFloat, length: CGFloat = 0.0, inset: CGFloat = 0.0, cornersInset: CGFloat = 0.0) -> UIView {
        let border = UIView()
        border.backgroundColor = color
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            switch side {
            case .left:
                if length != 0.0 {
                    make.height.equalTo(length)
                    make.centerY.equalToSuperview()
                } else {
                    make.top.equalToSuperview().inset(cornersInset)
                    make.bottom.equalToSuperview().inset(cornersInset)
                }
                make.left.equalToSuperview().inset(inset)
                make.width.equalTo(depth)
            case .top:
                if length != 0.0 {
                    make.width.equalTo(length)
                    make.centerX.equalToSuperview()
                } else {
                    make.left.equalToSuperview().inset(cornersInset)
                    make.right.equalToSuperview().inset(cornersInset)
                }
                make.top.equalToSuperview().inset(inset)
                make.height.equalTo(depth)
            case .right:
                if length != 0.0 {
                    make.height.equalTo(length)
                    make.centerY.equalToSuperview()
                } else {
                    make.top.equalToSuperview().inset(cornersInset)
                    make.bottom.equalToSuperview().inset(cornersInset)
                }
                make.right.equalToSuperview().inset(inset)
                make.width.equalTo(depth)
            case .bottom:
                if length != 0.0 {
                    make.width.equalTo(length)
                    make.centerX.equalToSuperview()
                } else {
                    make.left.equalToSuperview().inset(cornersInset)
                    make.right.equalToSuperview().inset(cornersInset)
                }
                make.bottom.equalToSuperview().inset(inset)
                make.height.equalTo(depth)
            }
        }
        return border
    }
    
    /// 快速添加子视图
    /// - Parameter subviews: 子视图
    func gd_addSubviews(_ subviews:[UIView]) {
        subviews.forEach({
            addSubview($0)
        })
    }
    
    /// 设置多个圆角
    ///
    /// - Parameters:
    ///   - cornerRadii: 圆角幅度
    ///   - roundingCorners: UIRectCorner(rawValue: (UIRectCorner.topRight.rawValue) | (UIRectCorner.bottomRight.rawValue))
    func filletedCorner(_ cornerRadii: CGSize, _ roundingCorners: UIRectCorner) {
        let fieldPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerRadii )
        let fieldLayer = CAShapeLayer()
        fieldLayer.frame = bounds
        fieldLayer.path = fieldPath.cgPath
        self.layer.mask = fieldLayer
    }
}

// MARK: 坐标和宽高
public extension UIView {
    var x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }

    var y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }

    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }

    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }

    func makeRoundedCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }

    func makeRoundedCorners() {
        makeRoundedCorners(bounds.size.width / 2)
    }

    func renderAsImage() -> UIImage? {
        var image: UIImage?
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
            image = renderer.image { _ in
                self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            }
        } else {
            // Fallback on earlier versions
            if let ctx = UIGraphicsGetCurrentContext() {
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
                self.layer.render(in: ctx)
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        return image
    }

    func blur(style: UIBlurEffect.Style) {
        unBlur()
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        insertSubview(blurEffectView, at: 0)
        blurEffectView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }

    func unBlur() {
        subviews.filter { (view) -> Bool in
            view as? UIVisualEffectView != nil
        }.forEach { (view) in
            view.removeFromSuperview()
        }
    }
}

// MARK: 原点和大小
public extension UIView {

    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }

    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame.size = newValue
        }
    }
}

// MARK: - 位置信息
public extension UIView {

    var bottomRight: CGPoint {
        let x: CGFloat = self.x + self.width
        let y: CGFloat = self.y + self.height
        return CGPoint(x: x, y: y)
    }

    var bottomLeft: CGPoint {
        let x: CGFloat = self.x
        let y: CGFloat = self.y + self.height
        return CGPoint(x: x, y: y)
    }

    var topRight: CGPoint {
        let x: CGFloat = self.x + self.width
        let y: CGFloat = self.y
        return CGPoint(x: x, y: y)
    }

    var top: CGFloat {
        get {
            return self.y
        }
        set {
            self.y = newValue
        }
    }

    var left: CGFloat {
        get {
            return self.x
        }
        set {
            self.x = newValue
        }
    }

    var bottom: CGFloat {
        get {
            return self.y + self.height
        }
        set {
            self.y = newValue - self.height
        }
    }

    var right: CGFloat {
        get {
            return self.x + self.width
        }
        set {
            self.x = newValue - self.width
        }
    }
}
