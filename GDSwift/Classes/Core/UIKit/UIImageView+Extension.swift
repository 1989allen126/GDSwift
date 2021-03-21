//
//  UIImageView+Extension.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

extension UIImageView {
    /**
     *设置web图片
     *url:图片路径
     *defaultImage:默认缺省图片
     *isCache：是否进行缓存的读取
     */
    func setWebImage(url:String?, defaultImage:UIImage?, isCache:Bool, downloadSuccess: ((_ image: UIImage?) -> Void)?) {
        var GDImage:UIImage?
        if url == nil {
            return
        }
        //设置默认图片
        if defaultImage != nil {
            self.image = defaultImage
        }
        
        if isCache {
            var data: Data? = GDCachingImageManager.readCacheFromUrl(url: url!)
            if data != nil {
                GDImage = UIImage(data: data!)
                self.image = GDImage
                if downloadSuccess != nil {
                    downloadSuccess!(GDImage)
                }
            }else{
                let dispath=DispatchQueue.global(qos: .utility)
                dispath.async(execute: { () -> Void in
                    do {
                        guard let imageURL = URL(string: url!) else {return}
                        data = try Data(contentsOf: imageURL)
                        if data != nil {
                            GDImage = UIImage(data: data!)
                            //写缓存
                            GDCachingImageManager.writeCacheToUrl(url: url!, data: data!)
                            DispatchQueue.main.async(execute: { () -> Void in
                                //刷新主UI
                                self.image = GDImage
                                if downloadSuccess != nil {
                                    downloadSuccess!(GDImage)
                                }
                            })
                        }
                    }
                    catch { print("下载图片失败")}
                })
            }
        } else {
            let dispath=DispatchQueue.global(qos: .utility)
            dispath.async(execute: { () -> Void in
                do {
                    guard let imageURL = URL(string: url!) else {return}
                    let data = try Data(contentsOf: imageURL)
                    GDImage = UIImage(data: data)
                    DispatchQueue.main.async(execute: { () -> Void in
                        //刷新主UI
                        self.image = GDImage
                        if downloadSuccess != nil {
                            downloadSuccess!(GDImage)
                        }
                    })
                }
                catch {print("下载图片失败")}
            })
        }
    }
}
