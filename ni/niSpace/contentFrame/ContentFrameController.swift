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
import FaviconFinder

class ContentFrameController: NSViewController, WKNavigationDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate{
    
    var niContentFrameView: ContentFrameView? = nil
    private var selectedTabModel: TabHeadModel? = nil
	private var tabs: [TabHeadModel] = []
	
	struct TabHeadModel{
		var url: String = ""
		var webView: NiWebView?
//		var headController: ContentFrameTabHead
		var icon: Favicon?
		var position: Int = -1
	}
	
    override func loadView() {
        self.niContentFrameView = (NSView.loadFromNib(nibName: "ContentFrameView", owner: self) as! ContentFrameView)
        self.view = niContentFrameView!
        self.view.wantsLayer = true
        self.view.layer?.cornerRadius = 10
        self.view.layer?.cornerCurve = .continuous
        self.view.layer?.borderWidth = 5
        self.view.layer?.borderColor = NSColor(.sandLight3).cgColor
        self.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
		
		niContentFrameView!.cfHeadView.wantsLayer = true
		niContentFrameView!.cfHeadView.layer?.backgroundColor = NSColor(.sandLight3).cgColor
    }
    

    private func getNewWebView(contentId: UUID, urlReq: URLRequest, frame: NSRect) -> NiWebView {

        let wkView = NiWebView(contentId: contentId, owner: self, frame: frame, configuration: WKWebViewConfiguration())
        wkView.load(urlReq)
        wkView.navigationDelegate = self
        return wkView
    }
    
    func openWebsiteInNewTab(urlStr: String, contentId: UUID, tabName: String) -> Int{
        let url = URL(string: urlStr) ?? URL(string: "https://www.google.com")
        let urlReq = URLRequest(url: url!)
        
        let niWebView = getNewWebView(contentId: contentId, urlReq: urlReq, frame: niContentFrameView!.frame)
        
        niWebView.navigationDelegate = self
		
		var tabHeadModel = TabHeadModel()
		tabHeadModel.position = niContentFrameView!.createNewTab(tabView: niWebView)
		tabHeadModel.url = urlStr
		tabHeadModel.webView = niWebView
		self.tabs.append(tabHeadModel)
		
		return tabHeadModel.position
    }
	
    func openWebsiteInNewTab(_ urlStr: String){
        let id = UUID()
        let pos = openWebsiteInNewTab(urlStr: urlStr, contentId: id, tabName: "")
//		niContentFrameView?.cfTabHeadCollection.reloadItems(at: Set(arrayLiteral: IndexPath(item: pos, section: 0)))
		niContentFrameView?.cfTabHeadCollection.reloadData()
		
		selectTab(at: pos)
    }
	
	func loadWebsiteInSelectedTab(_ url: URL){
		let urlReq = URLRequest(url: url)
		selectedTabModel?.webView?.load(urlReq)
	}
	
	/*
	 * MARK: - WKDelegate functions
	 */
	func webView(_ webView: WKWebView, didFinish: WKNavigation!){
		let wv = webView as! NiWebView
		wv.tabHead?.setTitle(wv.title ?? "")
		wv.tabHead?.setIcon(urlStr: wv.url!.absoluteString)
		wv.tabHead?.setURL(urlStr: wv.url!.absoluteString)
	}
	
	/*
	 * MARK: - Tab Heads collection control functions
	 */
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int{
		return self.tabs.count
	}
    
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ContentFrameTabHead"), for: indexPath)
		
		guard let tabHead = item as? ContentFrameTabHead else {return item}
		tabHead.view.wantsLayer = true
		tabHead.parentController = self
		tabHead.tabPosition = indexPath.item

		self.tabs[indexPath.item].webView?.tabHead = tabHead
		
		return tabHead
	}
	
	func selectTab(at: Int){
		self.selectedTabModel?.webView?.tabHead?.deselectSelf()
		
		self.niContentFrameView?.niContentTabView.selectTabViewItem(at: at)
		
		self.selectedTabModel = tabs[at]
	}
}
