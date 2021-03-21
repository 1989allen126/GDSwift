//
//  GDFakeNavigationBar.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

/// 模拟导航条
public class GDFakeNavigationBar: UIView {
    public enum Style {
        case `default`
        case lightContent
    }

    public class func bar(title: String?, backAction: (() -> Void)?, style: Style)
        -> GDFakeNavigationBar {
            let bar = GDFakeNavigationBar()
            bar.titleLabel.text = title
            bar.onBack = backAction
            bar.backButton.isHidden = (backAction == nil ? true : false)
            switch style {
            case .default:
                let image = UIImage.gdImageNamed(named: "ic_back_black")
                bar.backButton.setImage(image, for: .normal)
                bar.titleLabel.textColor = UIColor(hex: "#333333")
                bar.backgroundColor = UIColor.white
            case .lightContent:
                let image = UIImage.gdImageNamed(named: "ic_back_white")
                bar.backButton.setImage(image, for: .normal)
                bar.titleLabel.textColor = UIColor.white
            }
            return bar
    }

    fileprivate var onBack: (() -> Void)?
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    func setupBackAction(backAction: (() -> Void)?) {
        onBack = backAction
        self.backButton.isHidden = (backAction == nil ? true : false)
    }

    public let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.init(name: "PingFangSC-Semibold", size: 18)
            ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.font = font
        label.textAlignment = .center
        return label
    }()

    let backButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// 不适合在 IB 中创建
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("`init(coder:)` not implemented")
    }

    override public static var requiresConstraintBasedLayout: Bool {
        return true
    }
}

fileprivate extension GDFakeNavigationBar {
    func setup() {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(44)
        }

        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)

        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.left.greaterThanOrEqualTo(backButton.snp.right).offset(10)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        backButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 44, height: 30))
            $0.left.equalToSuperview()
            $0.centerY.equalTo(titleLabel.snp.centerY)
        }
    }

    @objc func backButtonClick() {
        onBack?()
    }
}
