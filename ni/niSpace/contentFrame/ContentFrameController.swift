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
	private var tabs: [TabHeadViewModel] = []
		
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
    
	func openEmptyTab() -> Int{
		let niWebView = NiWebView(contentId: UUID(), owner: self, frame: niContentFrameView!.frame, configuration: WKWebViewConfiguration())

		let localHTMLurl = Bundle.main.url(forResource: "emptyTab", withExtension: "html")!
		niWebView.loadFileURL(localHTMLurl, allowingReadAccessTo: localHTMLurl)
		
		let req = URLRequest(url: localHTMLurl)
		niWebView.navigationDelegate = self
		
		var tabHeadModel = TabHeadViewModel()
		tabHeadModel.position = niContentFrameView!.createNewTab(tabView: niWebView)
		tabHeadModel.webView = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		self.tabs.append(tabHeadModel)
		
		//Needs to be down here, as local websites will load before tab was added which creates problems in the webView on load call-back
		niWebView.load(req)
		
		selectTab(at: tabHeadModel.position)
		
		return tabHeadModel.position
	}
	
    func openWebsiteInNewTab(urlStr: String, contentId: UUID, tabName: String) -> Int{
        let url = URL(string: urlStr) ?? URL(string: "https://www.google.com")
        let urlReq = URLRequest(url: url!)
        
        let niWebView = getNewWebView(contentId: contentId, urlReq: urlReq, frame: niContentFrameView!.frame)
		
		var tabHeadModel = TabHeadViewModel()
		tabHeadModel.position = niContentFrameView!.createNewTab(tabView: niWebView)
		tabHeadModel.url = urlStr
		tabHeadModel.webView = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		self.tabs.append(tabHeadModel)
		
		selectTab(at: tabHeadModel.position)
		
		return tabHeadModel.position
    }
	
    func openWebsiteInNewTab(_ urlStr: String){
        let id = UUID()
        _ = openWebsiteInNewTab(urlStr: urlStr, contentId: id, tabName: "")
    }
	
	func loadWebsiteInSelectedTab(_ url: URL){
		let urlReq = URLRequest(url: url)
		tabs[selectedTabModel].webView?.load(urlReq)
	}
	
	func droppedInViewStack(){
		//TODO: pull the logic into the controller, as long as it does not have implications of the view
		niContentFrameView?.droppedInViewStack()
	}
	
	func toggleActive(){
		niContentFrameView?.toggleActive()
	}
	
	func persistContent(documentId: UUID){
		niContentFrameView?.persistContent(documentId: documentId)
	}
	
	func removeSelectedTab(){
		if(0 < selectedTabModel){
			let toDeletePos = selectedTabModel
			selectedTabModel -= 1
			
			niContentFrameView?.deleteSelectedTab(at: toDeletePos)
			self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
		}else if( selectedTabModel == 0 && self.tabs.count == 1){
			view.removeFromSuperview()
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
				removeSelectedTab()
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
//		self.tabs[wv.tabHeadPosition].icon = TODO: set icon here
		
		niContentFrameView?.cfTabHeadCollection.reloadItems(at: Set(arrayLiteral: IndexPath(item: wv.tabHeadPosition, section: 0)))
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
			return NSSize(width: 195, height: 22)
		}
		
		let maxWidth = (niContentFrameView?.cfTabHeadCollection.frame.width ?? 780) / 2
		var tabHeadWidth = CGFloat(viewModel.url.count) * 8.0 + 30
		
		if(maxWidth < tabHeadWidth){
			tabHeadWidth = maxWidth
		}
		
		return NSSize(width: tabHeadWidth, height: 22)
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
		tabs[selectedTabModel].inEditingMode = true
		niContentFrameView?.cfTabHeadCollection.reloadData()
	}
	
	func endEditingTabUrl(at: Int){
		self.aTabIsInEditingMode = false
		tabs[selectedTabModel].inEditingMode = false
		niContentFrameView?.cfTabHeadCollection.reloadData()
	}
}
