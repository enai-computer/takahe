//
//  NiWebViewController.swift
//  ni
//
//  Created by Patrick Lukas on 12/5/23.
//

import Foundation
import Cocoa
import WebKit


class NiWebViewController: NSViewController, WKNavigationDelegate{
    
    private let owner: ContentFrameView
    
    init(owner: ContentFrameView, urlReq: URLRequest, frame: NSRect) {
        self.owner = owner
        
        super.init(nibName: nil, bundle: nil)
        
        let wkView = NiWebView(owner: owner, frame: frame, configuration: WKWebViewConfiguration())
        wkView.load(urlReq)
        wkView.navigationDelegate = self
        
        self.view = wkView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//            if navigationAction.targetFrame == nil {
//                if let url = navigationAction.request.url {
//                    //TODO: open in new tab
//                }
//            }
//            decisionHandler(.allow)
//        }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        owner.niContentTabView.tabViewItems[0].label = webView.title ?? "0"
    }
}
