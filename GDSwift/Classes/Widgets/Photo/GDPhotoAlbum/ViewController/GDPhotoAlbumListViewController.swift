//
//  GDPhotoAlbumListViewController.swift
//  GDPhotoAlbum
//
//  Created by Apple on 2017/4/7.
//  Copyright © 2017年 qian.com. All rights reserved.
//

import UIKit
import Photos
import SnapKit

class GDPhotoAlbumListViewController: GDPhotoBaseViewController, UITableViewDelegate, UITableViewDataSource {

    weak var photoAlbumDelegate: GDPhotoAlbumProtocol?
    var type: GDPhotoAlbumType = .selectPhoto
    
    private var albumsList: [(assetCollection:PHAssetCollection, assetsFetchResult: PHFetchResult<PHAsset>)] = []
    private lazy var albumTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: NaviBarHeight, width: ScreenWidth, height: ScreenHeight-NaviBarHeight), style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initNavigation()
        self.view.addSubview(albumTableView)
        self.getAllAlbum()
    }

    //  MARK: - private method
    private func initNavigation() {
        self.setNavTitle(title: GDLocalizedString(key: "GD.Photo.title"))
        self.setRightTextButton(text: GDLocalizedString(key: "GD.Global.common.cancel"), color: UIColor.white)
        self.view.bringSubviewToFront(self.naviView)
    }
    
    private func getAllAlbum() {
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        fetchResult.enumerateObjects({ [unowned self] (assetCollection, index, nil) in
            let allOptions = PHFetchOptions()
            allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
            let assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: allOptions)
            guard assetsFetchResult.count <= 0 else {
                let assetItem = (assetCollection, assetsFetchResult)
                if assetCollection.assetCollectionSubtype == .smartAlbumVideos || assetCollection.assetCollectionSubtype == .smartAlbumSlomoVideos {
                    return
                }
                if assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    self.albumsList.insert(assetItem, at: 0)
                } else {
                    self.albumsList.append(assetItem)
                }
                return
            }
        })
        albumTableView.reloadData()
    }
    
    override func rightButtonClick(button: UIButton) {
        self.navigationController?.dismiss(animated: true)
    }
    
    //  MARK: - delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let album: PHAssetCollection = albumsList[indexPath.row].assetCollection
        
        var albumsCell: GDAlbumCell? = tableView.dequeueReusableCell(withIdentifier: "AlbumsCell") as? GDAlbumCell
        if albumsCell == nil {
            albumsCell = GDAlbumCell(style: .default, reuseIdentifier: "AlbumsCell")
        }
        albumsCell?.albumName = album.localizedTitle
        let photoResult = PHAsset.fetchAssets(in: album, options: nil)
        if photoResult.count != 0 {
            let asset = photoResult.lastObject
            _ = GDCachingImageManager.default().requestThumbnailImage(for: asset!, resultHandler: { (image: UIImage?, dictionry: Dictionary?) in
                albumsCell?.albumImage = image
            })
        }
        return albumsCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let assetsFetchResult = albumsList[indexPath.row].assetsFetchResult
        let photoAlbumViewController = GDPhotoAlbumViewController()
        photoAlbumViewController.assetsFetchResult = assetsFetchResult
        photoAlbumViewController.photoAlbumDelegate = self.photoAlbumDelegate
        photoAlbumViewController.type = self.type
        self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }

}

private class GDAlbumCell: UITableViewCell {
    
    var albumImage: UIImage? {
        didSet {
            albumImageView.image = albumImage
        }
    }
    
    var albumName: String? {
        didSet {
            albumNameLabel.text = albumName
        }
    }
    
    private lazy var cutLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 223/255.0, alpha: 1)
        return line
    }()
    
    private let albumImageView = UIImageView()
    private let albumNameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIElements()
    }
    
    func setupUIElements() {
        self.accessoryType = .disclosureIndicator
        albumImageView.contentMode = .scaleAspectFill
        albumImageView.clipsToBounds = true
        contentView.gd_addSubviews([albumImageView,albumNameLabel,cutLine])
        
        albumImageView.snp.makeConstraints({
            $0.top.left.bottom.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 0))
            $0.width.equalTo(albumImageView.snp.height)
        })
        
        albumNameLabel.snp.makeConstraints({
            $0.left.equalTo(albumImageView.snp.right).offset(10)
            $0.top.equalTo(albumImageView.snp.top)
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-2)
        })
        
        cutLine.snp.makeConstraints({
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(0.5)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
