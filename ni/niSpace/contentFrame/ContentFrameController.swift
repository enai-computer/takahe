//
//  ContentFrameController.swift
//  ni
//
//  Created by Patrick Lukas on 12/3/23.
//

import Foundation
import Cocoa
import WebKit
import QuartzCore

class ContentFrameController: NSViewController, WKNavigationDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate{
    
    var niContentFrameView: ContentFrameView? = nil
    var latestTab: Int = 0
    
    override func loadView() {
        self.niContentFrameView = (NSView.loadFromNib(nibName: "ContentFrameView", owner: self) as! ContentFrameView)
        self.view = niContentFrameView!
        self.view.wantsLayer = true
        self.view.layer?.cornerRadius = 10
        self.view.layer?.cornerCurve = .continuous
        self.view.layer?.borderWidth = 5
        self.view.layer?.borderColor = NSColor(.sandLight3).cgColor
        self.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
    }
    

    private func getNewWebView(contentId: UUID, urlReq: URLRequest, frame: NSRect) -> NiWebView {

        let wkView = NiWebView(contentId: contentId, owner: self, frame: frame, configuration: WKWebViewConfiguration())
        wkView.load(urlReq)
        wkView.navigationDelegate = self
        return wkView
    }
    
    func openWebsiteInNewTab(urlStr: String, contentId: UUID, tabName: String){
        let url = URL(string: urlStr) ?? URL(string: "https://www.google.com")
        let urlReq = URLRequest(url: url!)
        
        let niWebView = getNewWebView(contentId: contentId, urlReq: urlReq, frame: niContentFrameView!.frame)
        
        niWebView.navigationDelegate = self
        
        self.latestTab = niContentFrameView!.createNewTab(tabView: niWebView, label: tabName, urlStr: urlStr)
    }
    
    func openWebsiteInNewTab(_ urlStr: String){
        let id = UUID()
        openWebsiteInNewTab(urlStr: urlStr, contentId: id, tabName: "")
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let title = webView.title?.truncate(20)
        if title!.isEmpty{
            return
        }
        niContentFrameView!.niContentTabView.tabViewItems[latestTab].label = title!
        
    }
	
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int{
		return 1
	}
    
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ContentFrameTabHead"), for: indexPath)
		guard let tabHead = item as? ContentFrameTabHead else {return item}
		
		tabHead.view.wantsLayer = true
		
		return tabHead
	}
}
