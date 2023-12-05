//
//  ContentFrameController.swift
//  ni
//
//  Created by Patrick Lukas on 12/3/23.
//

import Foundation
import Cocoa
import WebKit

class ContentFrameController: NSViewController, WKNavigationDelegate{
    
    
    override func loadView() {
        self.view = NSView.loadFromNib(nibName: "ContentFrameView", owner: self)! as! ContentFrameView
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.targetFrame == nil {
                if let url = navigationAction.request.url {
                    //TODO: open in new tab
                }
            }
            decisionHandler(.allow)
        }

}
