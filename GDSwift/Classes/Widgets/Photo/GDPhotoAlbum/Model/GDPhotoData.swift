//
//  GDPhotoData.swift
//  GDPhotoAlbum
//
//  Created by Apple on 21/03/6.
//  Copyright © 2020年  apple.ln All rights reserved.
//

import UIKit
import Photos

class GDPhotoData: NSObject {
    // 判断数据是否发生变化
    var dataChanged = false
    // 存储每个cell选择标记（false：未选中，true：选中)
    var divideArray = [Bool]() {
        didSet {
            self.dataChanged = true
        }
    }
    //  相册所有图片数据源
    var assetArray = [PHAsset]()
    //  已选图片数组，数据类型是 PHAsset
    var seletedAssetArray = [PHAsset]()
}

public class GDPhotoModel: NSObject {
    // 缩略图
    public var thumbnailImage: UIImage?
    // 预览图
    public var originImage: UIImage?
    // 网络图URL
    public var imageURL: String?
    
    public convenience override init() {
        self.init(thumbnailImage: nil, originImage: nil, imageURL: nil)
    }
    
    public init(thumbnailImage: UIImage?, originImage: UIImage?, imageURL: String?) {
        self.thumbnailImage = thumbnailImage
        self.originImage = originImage
        self.imageURL = imageURL
    }
}
