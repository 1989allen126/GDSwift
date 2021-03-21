//
//  PhotoDemoViewController.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import GDSwift

class PhotoDemoViewController: BaseViewController {

    @IBOutlet weak var clipImage: UIImageView!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageThree: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
}

// MARK:- 初始化UI
extension PhotoDemoViewController:GDPhotoAlbumProtocol {
    fileprivate func initUI() {
        self.view.backgroundColor = UIColor.gray
        
        self.title = "测试图片";
    }
    
    @available(iOS 13.0, *)
    @IBAction func clipClick(_ sender: UIButton) {
        let photoAlbumVC = GDPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .clipPhoto)    //初始化需要设置代理对象
//        photoAlbumVC.clipBounds = CGSize(width: self.view.frame.width, height: 400)
        photoAlbumVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)

//        DispatchQueue.once(token: self.gd_token) {
//            
//        }
    }
    
    @IBAction func previewNetworkImage(_ sender: UIButton) {
        var imageModels = [GDPhotoModel]()
        var imageUrl = ["http://site.test.tf56.com/fastdfsWeb/dfs/group1/M00/03/F8/CgcN7Vj26fWAbmh8AAW9Qr9M7wI360.jpg",
            "http://site.test.tf56.com/fastdfsWeb/dfs/group1/M00/03/FA/CgcN7Fj26fSAWD7YAABjcoM6lB4696.jpg",
            "http://site.test.tf56.com/fastdfsWeb/dfs/group1/M00/04/13/CgcN7VkL6AeAfuhcABGDhv3Pwzc782.jpg"]
        for i in 0 ..< 3 {
            let model = GDPhotoModel(thumbnailImage: nil, originImage: nil, imageURL: imageUrl[i])
            imageModels.append(model)
        }
        let GDPhotoPreviewVC = GDPhotoPreviewDeleteViewController()
        GDPhotoPreviewVC.previewPhotoArray = imageModels
        GDPhotoPreviewVC.currentIndex = 0
        self.navigationController?.pushViewController(GDPhotoPreviewVC, animated: true)
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
//        GDPhotoAlbumSkinColor = UIColor.red   //修改主题色
        let photoAlbumVC = GDPhotoNavigationViewController(photoAlbumDelegate: self, photoAlbumType: .selectPhoto)    //初始化需要设置代理对象
        photoAlbumVC.maxSelectCount = 5    //最大可选择张数
        self.navigationController?.present(photoAlbumVC, animated: true, completion: nil)
    }
    
    func photoAlbum(selectPhotos: [GDPhotoModel]) {
        switch selectPhotos.count {
        case 1:
            imageOne.image = selectPhotos[0].thumbnailImage
        case 2:
            imageOne.image = selectPhotos[0].thumbnailImage
            imageTwo.image = selectPhotos[1].thumbnailImage
        case 3:
            imageOne.image = selectPhotos[0].thumbnailImage
            imageTwo.image = selectPhotos[1].thumbnailImage
            imageThree.image = selectPhotos[2].thumbnailImage
        default:
            break
        }
    }
    
    func photoAlbum(clipPhoto: UIImage?) {
        clipImage.image = clipPhoto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
