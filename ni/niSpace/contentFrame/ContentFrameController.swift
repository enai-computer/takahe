//
//  ContentFrameController.swift
//  ni
//
//  Created by Patrick Lukas on 12/3/23.
//

import Foundation
import Cocoa
import Carbon.HIToolbox
import WebKit
import QuartzCore
import FaviconFinder

//TODO: clean up tech debt and move the delegates out of here
class ContentFrameController: NSViewController, WKNavigationDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout{
    
    private(set) var niContentFrameView: ContentFrameView? = nil
    private var selectedTabModel: Int = -1
	private var aTabIsInEditingMode: Bool = false
	private var tabs: [TabViewModel] = []
		
    override func loadView() {
        self.niContentFrameView = (NSView.loadFromNib(nibName: "ContentFrameView", owner: self) as! ContentFrameView)
		self.niContentFrameView?.setSelfController(self)
        self.view = niContentFrameView!
        self.view.wantsLayer = true
        self.view.layer?.cornerRadius = 10
        self.view.layer?.cornerCurve = .continuous
        self.view.layer?.borderWidth = 5
        self.view.layer?.borderColor = NSColor(.sandLight4).cgColor
        self.view.layer?.backgroundColor = NSColor(.sandLight4).cgColor
		
		niContentFrameView!.cfHeadView.wantsLayer = true
		niContentFrameView!.cfHeadView.layer?.backgroundColor = NSColor(.sandLight4).cgColor
    }
    

    private func getNewWebView(contentId: UUID, urlReq: URLRequest, frame: NSRect) -> NiWebView {

        let wkView = NiWebView(contentId: contentId, owner: self, frame: frame, configuration: WKWebViewConfiguration())
        wkView.load(urlReq)
        wkView.navigationDelegate = self
        return wkView
    }
    
	func openEmptyTab(_ contentId: UUID = UUID()) -> Int{
		let niWebView = NiWebView(contentId: contentId, owner: self, frame: niContentFrameView!.frame, configuration: WKWebViewConfiguration())

		let localHTMLurl = getEmtpyWebViewURL()
		niWebView.loadFileURL(localHTMLurl, allowingReadAccessTo: localHTMLurl)
		
		let req = URLRequest(url: localHTMLurl)
		niWebView.navigationDelegate = self
		
		var tabHeadModel = TabViewModel(contentId: UUID())
		tabHeadModel.position = niContentFrameView!.createNewTab(tabView: niWebView)
		tabHeadModel.webView = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		self.tabs.append(tabHeadModel)
		
		//Needs to be down here, as local websites will load before tab was added which creates problems in the webView on load call-back
		niWebView.load(req)
		
		selectTab(at: tabHeadModel.position)
		
		return tabHeadModel.position
	}
	
	func openWebsiteInNewTab(urlStr: String, contentId: UUID, tabName: String, webContentState: String? = nil) -> Int{
		
		let url: URL
		do{
			url = try createWebUrl(from: urlStr)
		}catch{
			url = getCouldNotLoadWebViewURL()
		}

        let urlReq = URLRequest(url: url)
        
        let niWebView = getNewWebView(contentId: contentId, urlReq: urlReq, frame: niContentFrameView!.frame)
		
		var tabHeadModel = TabViewModel(contentId: contentId)
		tabHeadModel.position = niContentFrameView!.createNewTab(tabView: niWebView)
		tabHeadModel.url = urlStr
		tabHeadModel.webView = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		if(webContentState != nil){
			tabHeadModel.state = WebViewState(rawValue: webContentState!)!
		}else{
			tabHeadModel.state = .loading
		}
		
		self.tabs.append(tabHeadModel)
		
		selectTab(at: tabHeadModel.position)
		
		return tabHeadModel.position
    }
	
    func openWebsiteInNewTab(_ urlStr: String){
        let id = UUID()
        _ = openWebsiteInNewTab(urlStr: urlStr, contentId: id, tabName: "")
    }
	
	func loadWebsite(_ url: URL, forTab at: Int){
		let urlReq = URLRequest(url: url)
		
		tabs[at].state = .loading
		tabs[at].url = url.absoluteString
		tabs[at].webView?.load(urlReq)
	}
	
	func toggleActive(){
		niContentFrameView?.toggleActive()
	}
	
	func closeTab(at: Int){
		if(at != selectedTabModel){

			niContentFrameView?.deleteSelectedTab(at: at)
			self.tabs.remove(at: at)
			
			if (at < selectedTabModel){
				selectedTabModel -= 1
				tabs[selectedTabModel].webView?.tabHeadPosition = selectedTabModel
			}
			
			niContentFrameView?.cfTabHeadCollection.reloadData()
		}else {
			closeSelectedTab()
		}
	}
	
	func closeSelectedTab(){
		if(0 < selectedTabModel){
			let toDeletePos = selectedTabModel
			selectedTabModel -= 1
			
			niContentFrameView?.deleteSelectedTab(at: toDeletePos)
			self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
			
			niContentFrameView?.cfTabHeadCollection.reloadData()
		}else if( selectedTabModel == 0 && self.tabs.count == 1){
			view.removeFromSuperview()
		}else if( selectedTabModel == 0 && 1 < self.tabs.count){
			let toDeletePos = selectedTabModel
			
			niContentFrameView?.deleteSelectedTab(at: toDeletePos)
			self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
			
			niContentFrameView?.cfTabHeadCollection.reloadData()
		}
	}
	
	/*
	 * MARK: - keyboard caputure here:
	 */
	override func keyDown(with event: NSEvent) {
		if(event.modifierFlags.contains(.command)){
			if(event.keyCode == kVK_ANSI_T){
				_ = openEmptyTab()
				return
			}else if(event.keyCode == kVK_ANSI_W){
				closeSelectedTab()
				return
			}
		}
		nextResponder?.keyDown(with: event)
	}
	
	/*
	 * MARK: - WKDelegate functions
	 */
	func webView(_ webView: WKWebView, didFinish: WKNavigation!){
		let wv = webView as! NiWebView
		self.tabs[wv.tabHeadPosition].title = wv.title ?? ""
		self.tabs[wv.tabHeadPosition].url = wv.url!.absoluteString
		
		//an empty tab still loads a local html
		if(self.tabs[wv.tabHeadPosition].state != .empty && self.tabs[wv.tabHeadPosition].state != .error ){
			self.tabs[wv.tabHeadPosition].state = .loaded
			niContentFrameView?.cfTabHeadCollection.reloadItems(at: Set(arrayLiteral: IndexPath(item: wv.tabHeadPosition, section: 0)))
		}
		
	}
	
	func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error){
		let errorURL = getCouldNotLoadWebViewURL()
		webView.loadFileURL(errorURL, allowingReadAccessTo: errorURL.deletingLastPathComponent())
		
		guard let wv = webView as? NiWebView else{
			return
		}
		self.tabs[wv.tabHeadPosition].state = .error
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error){
		let errorURL = getCouldNotLoadWebViewURL()
		webView.loadFileURL(errorURL, allowingReadAccessTo: errorURL.deletingLastPathComponent())
		
		guard let wv = webView as? NiWebView else{
			return
		}
		self.tabs[wv.tabHeadPosition].state = .error
	}
	
	/*
	 * MARK: - Tab Heads collection control functions
	 */
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int{
		return self.tabs.count
	}
    
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		//After returning an item object from your collectionView(_:itemForRepresentedObjectAt:) method, you do not modify that object again.
		let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ContentFrameTabHead"), for: indexPath)
		
		guard let tabHead = item as? ContentFrameTabHead else {return item}

		tabHead.configureView(parentController: self, tabPosition: indexPath.item, viewModel: tabs[indexPath.item])
		
		return tabHead
	}
	
	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		
		let viewModel = tabs[indexPath.item]
		if(!viewModel.inEditingMode){
			return NSSize(width: 195, height: 30)
		}
		
		let maxWidth = (niContentFrameView?.cfTabHeadCollection.frame.width ?? 780) / 2
		var tabHeadWidth = CGFloat(viewModel.url.count) * 8.0 + 30
		
		if(maxWidth < tabHeadWidth){
			tabHeadWidth = maxWidth
		}
		
		if(tabHeadWidth < 200){
			tabHeadWidth = 200
		}
		
		return NSSize(width: tabHeadWidth, height: 30)
	}
	
	func collectionView(
		_ collectionView: NSCollectionView,
		layout collectionViewLayout: NSCollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int
	) -> CGFloat{
		return 4.00
	}
	
	func selectTab(at: Int, mouseDownEvent: NSEvent? = nil){
		
		//No tab switching while CF is not active
		if(!self.niContentFrameView!.frameIsActive){
			if(mouseDownEvent != nil){
				nextResponder?.mouseDown(with: mouseDownEvent!)
			}
			return
		}
		
		if(aTabIsInEditingMode && at != selectedTabModel){
			endEditingTabUrl(at: selectedTabModel)
		}
		
		if(aTabIsInEditingMode && at == selectedTabModel){
			return
		}
		
		if(0 <= selectedTabModel){
			tabs[selectedTabModel].isSelected = false
		}
		
		self.niContentFrameView?.niContentTabView.selectTabViewItem(at: at)
		
		self.selectedTabModel = at
		tabs[selectedTabModel].isSelected = true
		
		niContentFrameView?.cfTabHeadCollection.reloadData()
	}
	
	func editTabUrl(at: Int){
		self.aTabIsInEditingMode = true
		tabs[at].inEditingMode = true
		niContentFrameView?.cfTabHeadCollection.reloadData()
	}
	
	func endEditingTabUrl(at: Int){
		self.aTabIsInEditingMode = false
		tabs[at].inEditingMode = false
		
//		print("here the tabs[selectedTabModel].title should be set *if* the user commits instead of aborts changes")
		// This update interferes with the (async) web view callback and effectively defaults all editing operations to go to Google
		RunLoop.main.perform { [self] in
			niContentFrameView?.cfTabHeadCollection.reloadData()
		}
	}
	
	func setTabIcon(at: Int, icon: NSImage?){
		tabs[at].icon = icon
	}
	
	/*
	 * MARK: - store and load here
	 */
	func persistContent(documentId: UUID){
		for tab in tabs {
            CachedWebTable.upsert(documentId: documentId, id: tab.contentId, title: tab.title, url: tab.url)
		}
	}
	
	func toNiContentFrameModel() -> (model: NiDocumentObjectModel, nrOfTabs: Int){
		
		var children: [NiCFTabModel] = []
		
		for (i, tab) in tabs.enumerated(){
			children.append(
				NiCFTabModel(
					id: tab.contentId,
					contentType: NiCFTabContentType.web,
					contentState: tab.state.rawValue,
					active: true,
					position: i
				)
			)
		}
		
		
		//FIXME: this does not work :cry:
		let posInStack = Int(view.layer!.zPosition)
		let model = NiDocumentObjectModel(
			type: NiDocumentObjectTypes.contentFrame,
			data: NiContentFrameModel(
				state: NiConentFrameState.expanded,
				height: NiCoordinate(px: view.frame.height),
				width: NiCoordinate(px: view.frame.width),
				position: NiViewPosition(
					posInViewStack: posInStack,
					x: NiCoordinate(px: view.frame.origin.x),
					y: NiCoordinate(px: view.frame.origin.y)
				),
				children: children
			)
		)
		
		return (model: model, nrOfTabs: children.count)
	}
}
