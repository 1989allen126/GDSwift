//
//  GDPhotoPreviewViewController.swift
//  GDPhotoAlbum
//
//  Created by Apple on 21/03/2.
//  Copyright © 2020年  apple.ln All rights reserved.
//

import UIKit
import Photos

class GDPhotoPreviewViewController: GDPhotoBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var maxSelectCount = 0

    var currentIndex = 0
    //  数据源(预览选择时用)
    var photoData = GDPhotoData()
    //  浏览数据源
    var previewPhotoArray = [PHAsset]()
    //  完成闭包
    var sureClicked: ((_ view: UIView, _ selectPhotos: [PHAsset]) -> Void)?
    
    private let cellIdentifier = "PreviewCollectionCell"
    
    private var scrollDistance: CGFloat = 0
    private var willDisplayCellAndIndex: (cell: GDPreviewCollectionViewCell, indexPath: IndexPath)?
    private var isFirstCell = true
    
    private var requestIDs = [PHImageRequestID]()

    private lazy var photoCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: ScreenWidth+10, height: ScreenHeight)
        flowLayout.scrollDirection = .horizontal
        //  collectionView
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: ScreenWidth+10, height: ScreenHeight), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        //  添加协议方法
        collectionView.delegate = self
        collectionView.dataSource = self
        //  设置 cell
        collectionView.register(GDPreviewCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        return collectionView
    }()
    
    private lazy var bottomView = GDAlbumBottomView(type: .noPreview)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.black
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.photoCollectionView)
        self.initNavigation()
        self.setBottomView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.photoCollectionView.selectItem(at: IndexPath(item: self.currentIndex, section: 0), animated: false, scrollPosition: .left)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            for id in self.requestIDs {
                GDCachingImageManager.default().cancelImageRequest(id)
            }
        }
    }
    
    //  MARK:- private method
    private func initNavigation() {
        self.setBackNav()
        if let index = self.photoData.assetArray.index(of: self.previewPhotoArray[currentIndex]) {
            self.setRightImageButton(normalImage: UIImage.gdImageNamed(named: "ic_select_gray.png"), selectedImage: GDSelectSkinImage, isSelected: self.photoData.divideArray[index])
        }
        self.view.bringSubviewToFront(self.naviView)
    }
    
    private func setBottomView() {
        self.bottomView.rightClicked = { [unowned self] in
            if self.sureClicked != nil {
                self.sureClicked!(self.view, self.photoData.seletedAssetArray)
            }
        }
        self.view.addSubview(self.bottomView)
        bottomView.snp.makeConstraints({
            $0.left.bottom.right.equalTo(self.view)
            if #available(iOS 11.0, *) {
                $0.height.equalTo((UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0) + 44)
            } else {
                // Fallback on earlier versions
                $0.height.equalTo(44)
            }
        })
        self.completedButtonShow()
    }
    
    private func completedButtonShow() {
        if self.photoData.seletedAssetArray.count > 0 {
            self.bottomView.rightButtonTitle = String(format: GDLocalizedString(key: "GD.Photo.text.finished"), "\(self.photoData.seletedAssetArray.count)")
            self.bottomView.buttonIsEnabled = true
        } else {
            self.bottomView.rightButtonTitle = GDLocalizedString(key: "GD.Global.common.done")
            self.bottomView.buttonIsEnabled = false
        }
    }
    
    private func setPreviewImage(cell: GDPreviewCollectionViewCell, asset: PHAsset) {
        let pixelScale = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        let id = GDCachingImageManager.default().requestPreviewImage(for: asset, progressHandler: { (progress: Double, error: Error?, pointer: UnsafeMutablePointer<ObjCBool>, dictionry: Dictionary?) in
            //下载进度
            DispatchQueue.main.async {
                let progressView = GDProgressView.showGDProgressView(in: cell.contentView, frame: CGRect(x: cell.frame.width-20-12, y: cell.frame.midY+(cell.frame.width/pixelScale-20)/2-12, width: 20, height: 20))
                progressView.progress = progress
            }
        }, resultHandler: { (image: UIImage?, dictionry: Dictionary?) in
            var downloadFinined = true
            if let cancelled = dictionry![PHImageCancelledKey] as? Bool {
                downloadFinined = !cancelled
            }
            if downloadFinined, let error = dictionry![PHImageErrorKey] as? Bool {
                downloadFinined = !error
            }
            if downloadFinined, let resultIsDegraded = dictionry![PHImageResultIsDegradedKey] as? Bool {
                downloadFinined = !resultIsDegraded
            }
            if downloadFinined, let photoImage = image {
                cell.photoImage = photoImage
            }
        })
        self.requestIDs.append(id)
    }
    
    // handle events
    override func rightButtonClick(button: UIButton) {
        if let index = self.photoData.assetArray.index(of: self.previewPhotoArray[currentIndex]) {
            button.isSelected = !button.isSelected
            self.photoData.divideArray[index] = !self.photoData.divideArray[index]
            if self.photoData.divideArray[index] {
                if self.maxSelectCount != 0, self.photoData.seletedAssetArray.count >= self.maxSelectCount {
                    button.isSelected = false
                    //超过最大数
                    self.photoData.divideArray[index] = !self.photoData.divideArray[index]
                    
                    let message = String(format: GDLocalizedString(key: "GD.Photo.prompt.select"), "\(self.maxSelectCount)")
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let action = UIAlertAction(title: GDLocalizedString(key: "GD.Global.common.know"), style: .cancel, handler: nil)

                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                self.photoData.seletedAssetArray.append(self.previewPhotoArray[currentIndex])
            } else {
                self.photoData.seletedAssetArray.remove(at: self.photoData.seletedAssetArray.index(of: self.previewPhotoArray[currentIndex])!)
            }
            self.completedButtonShow()
        }
    }
    
    // MARK:- delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.previewPhotoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GDPreviewCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let asset = self.previewPhotoArray[indexPath.row]
        
        let id = GDCachingImageManager.default().requestThumbnailImage(for: asset) { (image: UIImage?, dictionry: Dictionary?) in
            (cell as! GDPreviewCollectionViewCell).photoImage = image ?? UIImage()
        }
        self.requestIDs.append(id)
        
        self.willDisplayCellAndIndex = (cell as! GDPreviewCollectionViewCell, indexPath)
        if indexPath.row == self.currentIndex && self.isFirstCell {
            self.isFirstCell = false
            self.setPreviewImage(cell: cell as! GDPreviewCollectionViewCell, asset: asset)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! GDPreviewCollectionViewCell).defaultScale = 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollDistance = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentIndex = Int(round(scrollView.contentOffset.x/scrollView.bounds.width))
        if self.currentIndex >= self.previewPhotoArray.count {
            self.currentIndex = self.previewPhotoArray.count-1
        } else if self.currentIndex < 0 {
            self.currentIndex = 0
        }
        if let index = self.photoData.assetArray.index(of: self.previewPhotoArray[self.currentIndex]) {
            self.rightButton.isSelected = self.photoData.divideArray[index]
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != self.scrollDistance {
            let currentCell = self.photoCollectionView.cellForItem(at: IndexPath(item: self.currentIndex, section: 0)) as! GDPreviewCollectionViewCell
            let asset = self.previewPhotoArray[self.currentIndex]
            self.setPreviewImage(cell: currentCell, asset: asset)
        }
    }
}
