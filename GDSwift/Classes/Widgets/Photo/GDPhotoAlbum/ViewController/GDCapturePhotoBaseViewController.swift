//
//  GDCapturePhotoBaseViewController.swift
//  GDSwift
//
//  Created by Jianglun Jin on 2021/3/20.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation
import CoreServices
import AVFoundation

class GDCapturePhotoBaseViewController: GDPhotoBaseViewController {
    
    public typealias GDCapturePhotoCompletionHandle = ((UIImage?) -> Void)
    var captureCompletionHandle: GDCapturePhotoCompletionHandle? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension GDCapturePhotoBaseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func capture(_ completion:@escaping GDCapturePhotoCompletionHandle) {

        captureCompletionHandle = completion

        #if arch(i386) || arch(x86_64)
        self.captureCompletionHandle?(nil)
        return
        #else

        checkCameraAuthStatusEx { [weak self] (granted) in
            if(granted) {
                let sourceType = UIImagePickerController.SourceType.camera
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = sourceType
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.delegate = self
                self?.present(imagePicker, animated: true, completion: nil)
            } else {

                let alert = UIAlertController(title: GDLocalizedString(key: "GD.Camera.Auth.tip"), message: GDLocalizedString(key: "GD.Camera.Auth.tip.content"), preferredStyle: .alert)
                let confirm = UIAlertAction(title: GDLocalizedString(key: "GD.Global.common.gotoSetting"), style: .default) { _ in
                    GDOpenURLSetting()
                }
                alert.addAction(confirm)

                let cancel = UIAlertAction(title: GDLocalizedString(key: "GD.Camera.Auth.cancel"), style: .default) { (_) in

                }
                alert.addAction(cancel)
                self?.present(alert, animated: true, completion: nil)
            }
        }
        #endif
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        })
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //拍照完成
            self.captureCompletionHandle?(image)
        }
    }
}
