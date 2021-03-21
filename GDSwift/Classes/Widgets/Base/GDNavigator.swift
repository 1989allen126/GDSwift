//
//  GDNavigator.swift
//  GDSwift
//
//  Created by apple on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import Hero
import SafariServices

protocol GDNavigatable {
    var navigator: GDNavigatable { get set }
}

class GDNavigator {
    static var `default` = GDNavigator()

    // MARK: - segues list, all app scenes
    enum Scene {
        case viewController(UIViewController)
        case safari(URL)
        case safariController(URL)
        case webController(URL)
    }

    enum Transition {
        case root(in: UIWindow)
        case navigation(type: HeroDefaultAnimationType)
        case customModal(type: HeroDefaultAnimationType)
        case modal
        case detail
        case alert
        case custom
    }

    // MARK: - get a single VC
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .viewController(let vc):
            return vc
        case .safari(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return nil

        case .safariController(let url):
            let vc = SFSafariViewController(url: url)
            return vc

        case .webController(let url):
            let vc = GDWebViewController()
            vc.loadURL(url)
            return vc

        }
    }

    func pop(sender: UIViewController?, toRoot: Bool = false) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else {
            sender?.navigationController?.popViewController(animated: true)
        }
    }

    func dismiss(sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - invoke a single segue
    func show(segue: Scene, sender: UIViewController?, transition: Transition = .navigation(type: .cover(direction: .left))) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, transition: transition)
        }
    }

    private func show(target: UIViewController, sender: UIViewController?, transition: Transition) {
        
        let finalSender = (sender != nil) ? sender:UIViewController.current
    
        switch transition {
        case .root(in: let window):
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = target
            }, completion: nil)
            return
        case .custom: return
        default: break
        }

        if let nav = sender as? UINavigationController {
            //push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }

        switch transition {
        case .navigation(let type):
            if let nav = finalSender?.navigationController {
                // push controller to navigation stack
                nav.hero.navigationAnimationType = .autoReverse(presenting: type)
                nav.pushViewController(target, animated: true)
            }
        case .customModal(let type):
            // present modally with custom animation
            DispatchQueue.main.async {
                let nav = GDBaseNavigationController(rootViewController: target)
                nav.hero.modalAnimationType = .autoReverse(presenting: type)
                finalSender?.present(nav, animated: true, completion: nil)
            }
        case .modal:
            // present modally
            DispatchQueue.main.async {
                let nav = GDBaseNavigationController(rootViewController: target)
                finalSender?.present(nav, animated: true, completion: nil)
            }
        case .detail:
            DispatchQueue.main.async {
                let nav = GDBaseNavigationController(rootViewController: target)
                finalSender?.showDetailViewController(nav, sender: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                finalSender?.present(target, animated: true, completion: nil)
            }
        default: break
        }
    }
}
