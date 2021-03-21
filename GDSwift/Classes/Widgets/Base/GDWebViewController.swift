//
//  GDWebViewController.swift
//  GDSwift
//
//  Created by apple on 2021/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WebKit

public enum GDWebviewControllerProgressIndicatorStyle {
    case activityIndicator
    case progressView
    case both
    case none
}

class GDWebViewController: GDBaseViewController,WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    private var customTitle:String? = ""
    
    // 进度条样式
    open var progressIndicatorStyle: GDWebviewControllerProgressIndicatorStyle = .progressView

    // 是否允许手势
    open var allowsBackForwardNavigationGestures: Bool {
        get {
            return webView.allowsBackForwardNavigationGestures
        }
        set(value) {
            webView.allowsBackForwardNavigationGestures = value
        }
    }

    //是否允许执行js脚本
    open var allowJavaScriptAlerts = true

    public var webView: WKWebView!

    let customNavigationBar: GDFakeNavigationBar = GDFakeNavigationBar.bar(title: "", backAction: nil, style: .lightContent)

    fileprivate var originUrl: String = ""

    // MARK: Private Properties
    fileprivate var progressView: UIProgressView!
    fileprivate var navControllerUsesBackSwipe: Bool = false
    lazy fileprivate var activityIndicator: UIActivityIndicatorView! = {
        var activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.2)
        #if swift(>=4.2)
        activityIndicator.style = .whiteLarge
        #else
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        #endif
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityIndicator)

        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[activityIndicator]-0-|", options: [], metrics: nil, views: ["activityIndicator": activityIndicator]))
        return activityIndicator
    }()

    // MARK: Public Methods
    open func loadURLWithString(_ URLString: String) {
        originUrl  = URLString
        if let URL = URL(string: URLString) {
            if (URL.scheme != "") && (URL.host != nil) {
                loadURL(URL)
            } else {
                loadURLWithString("http://\(URLString)")
            }
        } else {
            Logger.debug("error loadURLWithString \(URLString)")
        }
    }
    
    func setup(customTitle title:String?) {
        self.customTitle = title
        self.customNavigationBar.title = title
    }

    //加载网页
    open func loadURL(_ URL: Foundation.URL, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 0) {
        webView.load(URLRequest(url: URL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval))
    }

    //执行js脚本
    open func evaluateJavaScript(_ javaScriptString: String, completionHandler: ((AnyObject?, NSError?) -> Void)?) {
        webView.evaluateJavaScript(javaScriptString, completionHandler: completionHandler as! ((Any?, Error?) -> Void)?)
    }

    @objc open func goBack() {
        webView.goBack()
    }

    @objc open func goForward() {
        webView.goForward()
    }

    @objc open func stopLoading() {
        webView.stopLoading()
    }

    @objc open func reload() {
        webView.reload()
    }

    // MARK: WKNavigationDelegate Methods
    open func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }

    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showLoading(false)
        if error._code == NSURLErrorCancelled {
            return
        }

        showError(error.localizedDescription)
    }

    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showLoading(false)
        if error._code == NSURLErrorCancelled {
            return
        }
        showError(error.localizedDescription)
    }

    open func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }

    open func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
    }

    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showLoading(true)
    }

    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        decisionHandler(.allow)
        return
    }

    open func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }

    open func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            if url.description.lowercased().range(of: "http://") != nil || url.description.lowercased().range(of: "https://") != nil {
                webView.load(navigationAction.request)
            }
        }
        return nil
    }

    // MARK: WKUIDelegate Methods
    open func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if !allowJavaScriptAlerts {
            return
        }

        let alertController: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: GDLocalizedString(key: "GD.Global.common.confirm"), style: .cancel, handler: {(_: UIAlertAction) -> Void in
            completionHandler()
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

    }

    // MARK: 私有方法
    fileprivate func showError(_ errorString: String?) {
        let alertView = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: GDLocalizedString(key: "GD.Global.common.confirm"), style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }

    fileprivate func showLoading(_ animate: Bool) {
        if animate {
            if (progressIndicatorStyle == .activityIndicator) || (progressIndicatorStyle == .both) {
                activityIndicator.startAnimating()
            }
        } else if activityIndicator != nil {
            if (progressIndicatorStyle == .activityIndicator) || (progressIndicatorStyle == .both) {
                activityIndicator.stopAnimating()
            }
        }
    }

    fileprivate func progressChanged(_ newValue: NSNumber) {
        progressView.progress = newValue.floatValue
        if progressView.progress == 1 {
            progressView.progress = 0
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.progressView.alpha = 0
            })
        } else if progressView.alpha == 0 {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.progressView.alpha = 1
            })
        }
    }

    fileprivate func backForwardListChanged() {
        if self.navControllerUsesBackSwipe && self.allowsBackForwardNavigationGestures {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = !webView.canGoBack
        }
    }

    fileprivate func clearWebViewCache() {
        //iOS9.0以上使用的方法
        if #available(iOS 9.0, *) {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records) in
                for record in records {
                    //清除本站的cookie
                    if record.displayName.contains("xxxx.com") {//这个判断注释掉的话是清理所有的cookie
                        WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                            //清除成功
                            print("清除成功\(record)")
                        })
                    }
                }
            })
        } else {
            //ios8.0以上使用的方法
            let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
            let cookiesPath = libraryPath! + "/Cookies"
            try!FileManager.default.removeItem(atPath: cookiesPath)
        }
    }

    fileprivate func registerJavaScript() {
//        let registerMethods = []
//        registerMethods.forEach { (method) in
//
//            /*代码注入*/
//            let source = "function \(method)(msg) { window.webkit.messageHandlers[\(method)].postMessage(msg)}"
//            let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
//            webView.configuration.userContentController.addUserScript(userScript)
//
//            /*添加监听*/
//            webView.configuration.userContentController.add(self as WKScriptMessageHandler, name: method) // swiftlint:disable:this force_cast
//        }
    }

    fileprivate func callJavaScript(_ method: String, handle: ((Any?) -> Void)? = nil) {
        webView.evaluateJavaScript(method) { (resp, _) in
            handle?(resp)
        }
    }

    // MARK: KVO
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {return}
        switch keyPath {
        case "estimatedProgress":
            if (progressIndicatorStyle == .progressView) || (progressIndicatorStyle == .both) {
                if let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                    progressChanged(newValue)
                }
            }
        case "URL":
            break
        case "title":
            if(isEmptyString(content: self.customTitle)) {
                customNavigationBar.title = webView.title
            }
        case "loading":
            if let val = change?[NSKeyValueChangeKey.newKey] as? Bool {
                if !val {
                    showLoading(false)
                    backForwardListChanged()
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    // MARK: Overrides

    // Override this property getter to show bottom toolbar above other toolbars
    override open var edgesForExtendedLayout: UIRectEdge {
        get {
            return UIRectEdge(rawValue: super.edgesForExtendedLayout.rawValue ^ UIRectEdge.bottom.rawValue)
        }
        set {
            super.edgesForExtendedLayout = newValue
        }
    }

    // MARK: Life Cycle
    override open func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        view.backgroundColor = UIColor.white
        
        // 设置自定义导航
        customNavigationBar.backgroundColor = GDTheme.blue
        customNavigationBar.setupBackAction {
            [weak self] in

                guard let self = self else {
                    return
                }

                if (self.webView.canGoBack) {
                    self.goBack()
                } else {

                    self.clearWebViewCache()
                    self.navigationController?.popViewController(animated: true)
                }
        }
        
        addFakeNavigationBar()
        
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints {
            $0.height.equalTo(barHeight())
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
        }

        // Set up webView
        self.view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(barHeight())
            $0.left.right.bottom.equalToSuperview()
        }

        //进度条
        progressView = UIProgressView()
        progressView.alpha = 0
        self.view.addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(barHeight())
            $0.left.right.equalToSuperview()
            $0.height.equalTo(2)
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        tabBarController?.tabBar.isHidden = true
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.removeObserver(self, forKeyPath: "URL")
        webView.removeObserver(self, forKeyPath: "title")
        webView.removeObserver(self, forKeyPath: "loading")
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let navVC = self.navigationController {
            if let gestureRecognizer = navVC.interactivePopGestureRecognizer {
                navControllerUsesBackSwipe = gestureRecognizer.isEnabled
            } else {
                navControllerUsesBackSwipe = false
            }
        }
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navControllerUsesBackSwipe {
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        webView.stopLoading()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        //基本配置
        let config = WKWebViewConfiguration()
        //创建UserContentController（提供JavaScript向webView发送消息的方法）
        let userContent = WKUserContentController()

        //将UserConttentController设置到配置文件
        config.userContentController = userContent
        webView = WKWebView.init(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        /*注册方法*/
        registerJavaScript()
    }
}
