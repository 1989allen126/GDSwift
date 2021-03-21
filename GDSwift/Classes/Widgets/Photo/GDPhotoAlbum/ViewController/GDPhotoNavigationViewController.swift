//
//  GDPhotoNavigationViewController.swift
//  GDPhotoAlbum
//
//  Created by Apple on 2017/4/7.
//  Copyright © 2017年 qian.com. All rights reserved.
//

import UIKit
import Photos

// 主题色
public var GDPhotoAlbumSkinColor = UIColor(red: 0, green: 147/255.0, blue: 1, alpha: 1) {
    didSet {
        GDSelectSkinImage = UIImage.snapshotView(from: GDPhotoNavigationViewController.GDGetSelectView())!
    }
}
var GDSelectSkinImage: UIImage =  UIImage.snapshotView(from: GDPhotoNavigationViewController.GDGetSelectView())!

@objc public protocol GDPhotoAlbumProtocol: NSObjectProtocol {
    //返回图片原资源，需要用PHCachingImageManager或者我封装的GDCachingImageManager进行解析处理
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(selectPhotoAssets: [PHAsset]) -> Void
    
    //返回GDPhotoModel数组，其中包含选择的缩略图和预览图
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(selectPhotos: [GDPhotoModel]) -> Void
    
    // 返回裁剪后图片
    @available(iOS 8.0, *)
    @objc optional func photoAlbum(clipPhoto: UIImage?) -> Void
}

public enum GDPhotoAlbumType {
    case selectPhoto, clipPhoto
}

public class GDPhotoNavigationViewController: UINavigationController {

    // 最大选择张数
    public var maxSelectCount = 0 {
        didSet {
            self.photoAlbumVC.maxSelectCount = maxSelectCount
        }
    }
    
    // 裁剪大小
    public var clipBounds: CGSize = CGSize(width: ScreenWidth, height: ScreenWidth) {
        didSet {
            self.photoAlbumVC.clipBounds = clipBounds
        }
    }
    
    private let photoAlbumVC = GDPhotoAlbumViewController()
    
    private convenience init() {
        self.init(photoAlbumDelegate: nil, photoAlbumType: .selectPhoto)
    }
    
    public init(photoAlbumDelegate: GDPhotoAlbumProtocol?, photoAlbumType: GDPhotoAlbumType) {
        let photoAlbumListVC = GDPhotoAlbumListViewController()
        photoAlbumListVC.photoAlbumDelegate = photoAlbumDelegate
        photoAlbumListVC.type = photoAlbumType
        super.init(rootViewController: photoAlbumListVC)
        self.isNavigationBarHidden = true
        photoAlbumVC.photoAlbumDelegate = photoAlbumDelegate
        photoAlbumVC.type = photoAlbumType
        self.pushViewController(photoAlbumVC, animated: false)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    class func GDGetSelectView() -> UIView {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        view.backgroundColor = GDPhotoAlbumSkinColor
        view.image = UIImage.gdImageNamed(named: "ic_select_blue.png")
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
        return view
    }
}
