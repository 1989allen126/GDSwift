//
//  UIButton+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

// MARK: - 调整按钮图文样式
extension UIButton {

    /// 调整button图片和文本显示样式
    ///
    /// - Parameters:
    ///   - anImage: 图片
    ///   - title:   标题
    ///   - titlePosition: 标题相对位置
    ///   - additionalSpacing: 附加偏移量
    ///   - state: 状态
    @objc func set(image anImage: UIImage?, title: String,
                   titlePosition: UIView.ContentMode, additionalSpacing: CGFloat, state: UIControl.State) {

        // 设置图片
        self.imageView?.contentMode = .center
        self.setImage(anImage, for: state)

        positionLabelRespectToImage(title: title, position: titlePosition, spacing: additionalSpacing)

        // 设置文本
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
    }

    /// 内部方法
    ///
    /// - Parameters:
    ///   - title:    标题
    ///   - position: 位置
    ///   - spacing:  间隔
    private func positionLabelRespectToImage(title: String, position: UIView.ContentMode,
                                             spacing: CGFloat) {
        let imageSize = self.imageRect(forContentRect: self.frame)
        let titleFont = self.titleLabel?.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize) /*如果没有设置,默认使用系统默认*/
        let titleSize = NSString(string: title).size(withAttributes: [NSAttributedString.Key.font: titleFont])

        var titleInsets: UIEdgeInsets = .zero
        var imageInsets: UIEdgeInsets = .zero

        switch (position) {
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                       right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
    }
}
