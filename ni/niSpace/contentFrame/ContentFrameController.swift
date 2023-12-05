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
    
    var niContentFrameView: ContentFrameView? = nil
    var latestTab: Int = 0
    
    override func loadView() {
        self.niContentFrameView = NSView.loadFromNib(nibName: "ContentFrameView", owner: self)! as! ContentFrameView
        self.view = niContentFrameView!
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
    }
    

    private func getNewWebView(urlReq: URLRequest, frame: NSRect) -> NiWebView {

        let wkView = NiWebView(owner: self, frame: frame, configuration: WKWebViewConfiguration())
        wkView.load(urlReq)
        wkView.navigationDelegate = self
        return wkView
    }
    
    func openWebsiteInNewTab(_ urlStr: String){
        let urlReq = URLRequest(url: URL(string: urlStr)!)
        
        let niWebView = getNewWebView(urlReq: urlReq, frame: niContentFrameView!.frame)
        
        niWebView.navigationDelegate = self
        
        self.latestTab = niContentFrameView!.createNewTab(tabView: niWebView, label: "", urlStr: urlStr)
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
       debugPrint("didCommit")
   }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let title = webView.title?.truncate(20)
        if title!.isEmpty{
            return
        }
        niContentFrameView!.niContentTabView.tabViewItems[latestTab].label = title!
        
    }
    
}
