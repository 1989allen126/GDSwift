//
//  GDPhotoAlbumViewController.swift
//  GDPhotoAlbum
//
//  Created by Apple on 16/11/29.
//  Copyright © 2020年  apple.ln All rights reserved.
//

import UIKit
import Photos
import SnapKit

class GDPhotoAlbumViewController: GDPhotoBaseViewController, PHPhotoLibraryChangeObserver, UICollectionViewDelegate, UICollectionViewDataSource {

    var assetsFetchResult: PHFetchResult<PHAsset>?
    var maxSelectCount = 0
    var type: GDPhotoAlbumType = .selectPhoto
    
    // 剪裁大小
    var clipBounds: CGSize = CGSize(width: GDScreenWidth, height: GDScreenWidth)
    weak var photoAlbumDelegate: GDPhotoAlbumProtocol?
    
    private let cellIdentifier = "PhotoCollectionCell"
    private lazy var photoCollectionView: UICollectionView = {
        // 竖屏时每行显示4张图片
        let shape: CGFloat = 5
        let cellWidth: CGFloat = (GDScreenWidth - 5 * shape) / 4
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 6, left: shape, bottom: self.type == .selectPhoto ? 44:0, right: shape)
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumLineSpacing = shape
        flowLayout.minimumInteritemSpacing = shape
        //  collectionView
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: NaviBarHeight, width: GDScreenWidth, height: GDScreenHeight - NaviBarHeight), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        //  添加协议方法
        collectionView.delegate = self
        collectionView.dataSource = self
        //  设置 cell
        collectionView.register(GDPhotoCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
//        collectionView.contentInset = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return collectionView
    }()
    
    private var bottomView = GDAlbumBottomView()
    private lazy var loadingView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: NaviBarHeight, width: GDScreenWidth, height: GDScreenHeight-NaviBarHeight))
        view.backgroundColor = UIColor.clear
        let loadingBackView = UIView(frame: CGRect(x: view.frame.width/2-30, y: view.frame.height/2-32-30, width: 60, height: 60))
        loadingBackView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        loadingBackView.layer.cornerRadius = 10;
        loadingBackView.clipsToBounds = true
        view.addSubview(loadingBackView)
        let loading = UIActivityIndicatorView(style: .whiteLarge)
        loading.center = CGPoint(x: 30, y: 30)
        loading.startAnimating()
        loadingBackView.addSubview(loading)
        return view
    }()
    
    //  数据源
    private var photoData = GDPhotoData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.photoCollectionView)
        self.initNavigation()
        if type == .selectPhoto {
            self.setBottomView()
        }
        self.getAllPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        if self.photoData.dataChanged {
            self.photoCollectionView.reloadData()
            self.completedButtonShow()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.photoData.dataChanged = false
    }
    
    //  MARK:- private method
    private func initNavigation() {
        self.setNavTitle(title: GDLocalizedString(key: "GD.Photo.text.all"))
        self.setBackNav()
        self.setRightTextButton(text: GDLocalizedString(key: "GD.Global.common.cancel"), color: UIColor.white)
        self.view.bringSubviewToFront(self.naviView)
    }
    
    private func setBottomView() {
        self.bottomView.leftClicked = { [unowned self] in
            self.gotoPreviewViewController(previewArray: self.photoData.seletedAssetArray, currentIndex: 0)
        }
        self.bottomView.rightClicked = { [unowned self] in
            self.selectSuccess(fromeView: self.view, selectAssetArray: self.photoData.seletedAssetArray)
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
    }
    
    private func getAllPhotos() {
        //  注意点！！-这里必须注册通知，不然第一次运行程序时获取不到图片，以后运行会正常显示。体验方式：每次运行项目时修改一下 Bundle Identifier，就可以看到效果。
        PHPhotoLibrary.shared().register(self)
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted || status == .denied {
            // 无权限
            // do something...
            print("无权限")
            let alert = UIAlertController(title: nil, message: GDLocalizedString(key: "GD.Photo.pop.openAlbum.title"), preferredStyle: .alert)
            let cancleAction = UIAlertAction(title: GDLocalizedString(key: "GD.Global.common.cancel"), style: .cancel, handler: nil)
            alert.addAction(cancleAction)
            let goAction = UIAlertAction(title: GDLocalizedString(key: "GD.Global.common.setting"), style: .default, handler: { (action) in
                GDOpenURLSetting()
            })
            
            alert.addAction(goAction)
            self.present(alert, animated: true, completion: nil)
            return;
        }
        
        //  获取所有系统图片信息集合体
        let allOptions = PHFetchOptions()
        //  对内部元素排序，按照时间由远到近排序
        allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        //  将元素集合拆解开，此时 allResults 内部是一个个的PHAsset单元
        let fetchAssets = assetsFetchResult ?? PHAsset.fetchAssets(with: allOptions)
        self.photoData.assetArray = fetchAssets.objects(at: IndexSet.init(integersIn: 0..<fetchAssets.count))
        
        self.photoData.divideArray = Array(repeating: false, count: self.photoData.assetArray.count)
    }
    
    private func selectSuccess(fromeView: UIView, selectAssetArray: [PHAsset]) {
        self.showLoadingView(inView: fromeView)
        var selectPhotos: [GDPhotoModel] = Array(repeating: GDPhotoModel(), count: selectAssetArray.count)
        let group = DispatchGroup()
        for i in 0 ..< selectAssetArray.count {
            let asset = selectAssetArray[i]
            group.enter()
            let photoModel = GDPhotoModel()
            _ = GDCachingImageManager.default().requestThumbnailImage(for: asset, resultHandler: { (image: UIImage?, dictionry: Dictionary?) in
                photoModel.thumbnailImage = image
            })
            _ = GDCachingImageManager.default().requestPreviewImage(for: asset, progressHandler: nil, resultHandler: { (image: UIImage?, dictionry: Dictionary?) in
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
                    photoModel.originImage = photoImage
                    selectPhotos[i] = photoModel
                    group.leave()
                }
            })
        }
        group.notify(queue: DispatchQueue.main, execute: {
            self.hideLoadingView()
            if self.photoAlbumDelegate != nil {
                if self.photoAlbumDelegate!.responds(to: #selector(GDPhotoAlbumProtocol.photoAlbum(selectPhotoAssets:))){
                    self.photoAlbumDelegate?.photoAlbum!(selectPhotoAssets: selectAssetArray)
                }
                if self.photoAlbumDelegate!.responds(to: #selector(GDPhotoAlbumProtocol.photoAlbum(selectPhotos:))) {
                    self.photoAlbumDelegate?.photoAlbum!(selectPhotos: selectPhotos)
                }
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    private func completedButtonShow() {
        if self.photoData.seletedAssetArray.count > 0 {
            self.bottomView.rightButtonTitle =  String(format: GDLocalizedString(key: "GD.Photo.text.finished"), "\(self.photoData.seletedAssetArray.count)")
            self.bottomView.buttonIsEnabled = true
        } else {
            self.bottomView.rightButtonTitle = GDLocalizedString(key: "GD.Global.common.done")
            self.bottomView.buttonIsEnabled = false
        }
    }
    
    private func showLoadingView(inView: UIView) {
        inView.addSubview(loadingView)
    }
    private func hideLoadingView() {
        loadingView.removeFromSuperview()
    }
    
    // MARK:- handle events
    private func gotoPreviewViewController(previewArray: [PHAsset], currentIndex: Int) {
        let previewVC = GDPhotoPreviewViewController()
        previewVC.maxSelectCount = maxSelectCount
        previewVC.currentIndex = currentIndex
        previewVC.photoData = self.photoData
        previewVC.previewPhotoArray = previewArray
        previewVC.sureClicked = { [unowned self] (view: UIView, selectPhotos: [PHAsset]) in
            self.selectSuccess(fromeView: view, selectAssetArray: selectPhotos)
        }
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    private func gotoClipViewController(photoImage: UIImage) {
        let clipVC = GDPhotoClipViewController()
        clipVC.clipBounds = self.clipBounds
        clipVC.photoImage = photoImage
        clipVC.sureClicked = { [unowned self] (clipPhoto: UIImage?) in
            if self.photoAlbumDelegate != nil, self.photoAlbumDelegate!.responds(to: #selector(GDPhotoAlbumProtocol.photoAlbum(clipPhoto:))) {
                self.photoAlbumDelegate?.photoAlbum!(clipPhoto: clipPhoto)
            }
            self.dismiss(animated: true, completion: nil)
        }
        self.navigationController?.pushViewController(clipVC, animated: true)
    }
    
    override func rightButtonClick(button: UIButton) {
        self.navigationController?.dismiss(animated: true)
    }
    
    // MARK:- delegate
    //  PHPhotoLibraryChangeObserver  第一次获取相册信息，这个方法只会进入一次
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.getAllPhotos()
            self.photoCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoData.assetArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GDPhotoCollectionViewCell
        let asset = self.photoData.assetArray[indexPath.row]
        _ = GDCachingImageManager.default().requestThumbnailImage(for: asset) { (image: UIImage?, dictionry: Dictionary?) in
            cell.photoImage = image ?? UIImage()
        }
        if type == .selectPhoto {
            cell.isChoose = self.photoData.divideArray[indexPath.row]
            cell.selectPhotoCompleted = { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.photoData.divideArray[indexPath.row] = !strongSelf.photoData.divideArray[indexPath.row]
                if strongSelf.photoData.divideArray[indexPath.row] {
                    if strongSelf.maxSelectCount != 0, strongSelf.photoData.seletedAssetArray.count >= strongSelf.maxSelectCount {
                        cell.isChoose = false
                        //超过最大数
                        strongSelf.photoData.divideArray[indexPath.row] = !strongSelf.photoData.divideArray[indexPath.row]
                        let message = String(format: GDLocalizedString(key: "GD.Photo.prompt.select"), "\(strongSelf.maxSelectCount)")
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let action = UIAlertAction(title: GDLocalizedString(key: "GD.Global.common.know"), style: .cancel, handler: nil)
                        alert.addAction(action)
                        strongSelf.present(alert, animated: true, completion: nil)
                        return
                    }
                    strongSelf.photoData.seletedAssetArray.append(strongSelf.photoData.assetArray[indexPath.row])
                } else {
                    strongSelf.photoData.seletedAssetArray.remove(at: strongSelf.photoData.seletedAssetArray.firstIndex(of: strongSelf.photoData.assetArray[indexPath.row])!)
                }
                strongSelf.completedButtonShow()
            }
        } else {
            cell.selectButton.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.type == .selectPhoto {
            self.gotoPreviewViewController(previewArray: self.photoData.assetArray, currentIndex: indexPath.row)
        } else {
            self.showLoadingView(inView: self.view)
            let asset = self.photoData.assetArray[indexPath.row]
            _ = GDCachingImageManager.default().requestPreviewImage(for: asset, progressHandler: nil, resultHandler: { (image: UIImage?, dictionry: Dictionary?) in
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
                    self.hideLoadingView()
                    self.gotoClipViewController(photoImage: photoImage)
                }
            })
        }
    }
}

// 相册底部view
class GDAlbumBottomView: UIView {
    
    private lazy var previewButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 12, y: 2, width: 60, height: 40))
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitle(GDLocalizedString(key: "GD.Photo.text.preview"), for: .normal)
        button.setTitleColor(UIColor(white: 0.5, alpha: 1), for: .disabled)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(previewClick(button:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var sureButton: UIButton = {
        let button = UIButton(frame: CGRect(x: GDScreenWidth-12-64, y: 6, width: 64, height: 32))
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(GDLocalizedString(key: "GD.Global.common.done"), for: .normal)
        button.setBackgroundImage(UIImage.pixel(ofColor: GDPhotoAlbumSkinColor), for: .normal)
        button.setBackgroundImage(UIImage.pixel(ofColor: GDPhotoAlbumSkinColor.withAlphaComponent(0.5)), for: .disabled)
        button.setTitleColor(UIColor(white: 0.5, alpha: 1), for: .disabled)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(sureClick(button:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    var leftButtonTitle: String? {
        didSet {
            self.previewButton.setTitle(leftButtonTitle, for: .normal)
        }
    }
    
    var rightButtonTitle: String? {
        didSet {
            self.sureButton.setTitle(rightButtonTitle, for: .normal)
        }
    }
    
    var buttonIsEnabled = false {
        didSet {
            self.previewButton.isEnabled = buttonIsEnabled
            self.sureButton.isEnabled = buttonIsEnabled
        }
    }
    
    // 预览闭包
    var leftClicked: (() -> Void)?
    
    // 完成闭包
    var rightClicked: (() -> Void)?
    
    enum GDAlbumBottomViewType {
        case normal, noPreview
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: GDScreenHeight-44, width: GDScreenWidth, height: 44), type: .normal)
    }
    
    convenience init(type: GDAlbumBottomViewType) {
        self.init(frame: CGRect(x: 0, y: GDScreenHeight-44, width: GDScreenWidth, height: 44), type: type)
    }
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame, type: .normal)
    }
    
    init(frame: CGRect, type: GDAlbumBottomViewType) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        if type == .normal {
            self.addSubview(self.previewButton)
        }
        
        self.addSubview(self.sureButton)
        let cutLine = UIView()
        cutLine.backgroundColor = UIColor(hex: "#DFDFDF")
        self.addSubview(cutLine)
        cutLine.snp.makeConstraints({
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: handle events
    @objc func previewClick(button: UIButton) {
        leftClicked?()
    }
    
    @objc func sureClick(button: UIButton) {
        rightClicked?()
    }
}
