//
//  GDPhotoBaseViewController.swift
//  GDPhotoAlbum
//
//  Created by Apple on 16/11/29.
//  Copyright © 2020年  apple.ln All rights reserved.
//

import UIKit

let GDScreenWidth: CGFloat = UIScreen.main.bounds.size.width
let GDScreenHeight: CGFloat = UIScreen.main.bounds.size.height

public class GDPhotoBaseViewController: UIViewController {

    let naviView = UIView(frame: CGRect(x: 0, y: 0, width: GDScreenWidth, height: NaviBarHeight))
    
    lazy var rightButton: UIButton = {
        let rightButton = UIButton()
        rightButton.frame = CGRect(x: GDScreenWidth-50, y: NaviBarHeight - 44, width: 50, height: 44)
        rightButton.backgroundColor = UIColor.clear
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        rightButton.addTarget(self, action: #selector(rightButtonClick(button:)), for: .touchUpInside)
        return rightButton
    }()
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect(x: GDScreenWidth/2-50, y: NaviBarHeight - 44, width: 100, height: 44))
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        return titleLabel
    }()
    
    private var recordHistoryNaviBarHiddenStatus:Bool = false
    
    public override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        recordHistoryNaviBarHiddenStatus = self.navigationController?.navigationBar.isHidden ?? false

        // Do any additional setup after loading the view.
        if !recordHistoryNaviBarHiddenStatus {
            self.navigationController?.navigationBar.isHidden = true
        }
        self.setNavigationView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !recordHistoryNaviBarHiddenStatus {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !recordHistoryNaviBarHiddenStatus {
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    fileprivate func setNavigationView() {
        
        naviView.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        view.addSubview(naviView)
    }
    
    func setBackNav() {
        let backImage = UIImage.gdImageNamed(named: "ic_back_white.png")
        let backButton = UIButton(frame: CGRect(x: 0, y: NaviBarHeight - 44, width: 50, height: 44))
        backButton.backgroundColor = UIColor.clear
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(backClick(button:)), for: .touchUpInside)
        naviView.addSubview(backButton)
    }
    
    func setNavTitle(title: String?) {
        titleLabel.text = title
        if !titleLabel.isDescendant(of: naviView) {
            naviView.addSubview(titleLabel)
        }
    }
    
    func setRightTextButton(text: String?, color: UIColor) {
        rightButton.setTitle(text, for: .normal)
        rightButton.setTitleColor(color, for: .normal)
        naviView.addSubview(rightButton)
    }

    func setRightImageButton(normalImage: UIImage?, selectedImage: UIImage?, isSelected: Bool) {
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 13)
        rightButton.setImage(normalImage, for: .normal)
        rightButton.setImage(selectedImage, for: .selected)
        rightButton.isSelected = isSelected
        naviView.addSubview(rightButton)
    }
    
    @objc func backClick(button: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @objc func rightButtonClick(button: UIButton) {
        
    }
    
}
