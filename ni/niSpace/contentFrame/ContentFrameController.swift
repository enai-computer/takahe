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
class ContentFrameController: NSViewController, WKNavigationDelegate, WKUIDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout{
    
	var myView: CFBaseView {return self.view as! CFBaseView}
	
    private(set) var expandedCFView: ContentFrameView? = nil
    private var selectedTabModel: Int = -1
	private(set) var aTabIsInEditingMode: Bool = false
	private var tabs: [TabViewModel] = []
	private var viewState: NiConentFrameState = .expanded
		
	/*
	 * MARK: init & view loading here
	 */
	init(viewState: NiConentFrameState, tabsModel: [TabViewModel]? = nil){
		self.viewState = viewState
		
		if(tabsModel != nil){
			self.tabs = tabsModel!
		}
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func loadView() {
		if(viewState == .minimised){
			loadAndDisplayMinimizedView()
		}else{
			loadAndDisplayDefaultView()
		}
    }
    
	private func loadAndDisplayDefaultView(){
		loadExpandedView()
		self.view = expandedCFView!
		sharedLoadViewSetters()
	}
	
	private func loadExpandedView(){
		self.expandedCFView = (NSView.loadFromNib(nibName: "ContentFrameView", owner: self) as! ContentFrameView)
		self.expandedCFView?.setSelfController(self)
		self.expandedCFView?.initAfterViewLoad()

		expandedCFView!.cfHeadView.wantsLayer = true
		expandedCFView!.cfHeadView.layer?.backgroundColor = NSColor(.sandLight4).cgColor
	}
	
	private func loadAndDisplayMinimizedView(){
		let minimizedView = loadMinimizedView()
		self.view = minimizedView
		sharedLoadViewSetters()
	}
	
	private func loadMinimizedView() -> CFMinimizedView{
		let minimizedView = (NSView.loadFromNib(nibName: "CFMinimizedView", owner: self) as! CFMinimizedView)
		
		//if loaded when space is generated from storage this value will be overwritten
		minimizedView.setFrameOwner(expandedCFView?.niParentDoc)
		minimizedView.setSelfController(self)
		
		let stackItems = genMinimizedStackItems(tabs: tabs, owner: self)
		minimizedView.listOfTabs?.setViews(stackItems, in: .top)

		minimizedView.initAfterViewLoad(nrOfItems: stackItems.count)
		
		self.viewState = .minimised
		
		return minimizedView
	}
	
	private func sharedLoadViewSetters(){
		self.view.wantsLayer = true
		self.view.layer?.cornerRadius = 10
		self.view.layer?.cornerCurve = .continuous
		self.view.layer?.borderWidth = 5
		self.view.layer?.borderColor = NSColor(.sandLight4).cgColor
		self.view.layer?.backgroundColor = NSColor(.sandLight4).cgColor
	}
	
	/*
	 * MARK: passToView Functions
	 */
	func toggleActive(){
		myView.toggleActive()
	}
	
	func reloadSelectedTab(){
		if(viewState != .minimised){
			tabs[selectedTabModel].webView?.reload()
		}
	}
	
	/*
	 * MARK: minimizing and maximizing
	 */
	private func minimizeSelf(){
		updateTabViewModel()
		let minimizedView = loadMinimizedView()
		
		//position
		minimizedView.frame.origin.y = self.view.frame.origin.y
		minimizedView.frame.origin.x = self.view.frame.origin.x + self.view.frame.width - minimizedView.frame.width
		if(self.view.layer != nil){
			minimizedView.layer?.zPosition = self.view.layer!.zPosition
		}
		
		//replace
		self.view.superview?.replaceSubview(self.view, with: minimizedView)
		
		self.view = minimizedView
		sharedLoadViewSetters()
		
		self.myView.niParentDoc?.setTopNiFrame(self)
	}
	
	
	func minimizeClicked(_ event: NSEvent) {
		minimizeSelf()
	}
	
	
	func maximizeClicked(_ event: NSEvent){
		if(viewState == .minimised){
			minimizedToExpanded()
		}
	}
	
	func minimizedToExpanded(_ selectTabAt: Int = -1){
		if(expandedCFView == nil){
			recreateExpandedCFView()
			expandedCFView?.setFrameOwner(self.myView.niParentDoc)
		}
		//position
		//TODO: ensure it's not out of bounds?
		expandedCFView!.frame.origin.y = self.view.frame.origin.y
		expandedCFView!.frame.origin.x = self.view.frame.origin.x + self.view.frame.width - expandedCFView!.frame.width
		if(self.view.layer != nil){
			expandedCFView!.layer?.zPosition = self.view.layer!.zPosition
		}
		
		//replace
		self.view.superview?.replaceSubview(self.view, with: expandedCFView!)
		self.view = expandedCFView!
		
		self.viewState = .expanded
		if(0 <= selectTabAt){
			forceSelectTab(at: selectTabAt)
		}
		
		self.expandedCFView!.niParentDoc?.setTopNiFrame(self)
		
	}
	
	func recreateExpandedCFView() {
		loadExpandedView()
		for i in tabs.indices{
			let wview = getNewWebView(owner: self, frame: expandedCFView!.frame ,cleanUrl: tabs[i].url, contentId: tabs[i].contentId)
			tabs[i].webView = wview
			tabs[i].position = expandedCFView!.createNewTab(tabView: wview)
			wview.tabHeadPosition = tabs[i].position
			if(tabs[i].isSelected){
				selectedTabModel = i
			}
		}
	}
	
	/*
	 * MARK: tabViewModel consistency
	 */
	private func updateTabViewModel(){
		for i in tabs.indices{
			if(tabs[i].webView != nil){
				if(tabs[i].webView!.title != nil){
					tabs[i].title = tabs[i].webView!.title!
				}
				if(tabs[i].webView!.url != nil){
					tabs[i].url = tabs[i].webView!.url!.absoluteString
				}
			}
			if(i == selectedTabModel){
				tabs[i].isSelected = true
			}else{
				tabs[i].isSelected = false
			}
		}
	}
	
	/*
	 * MARK: opening tabs
	 */
	func openEmptyTab(_ contentId: UUID = UUID()) -> Int{
		let niWebView = ni.getNewWebView(owner: self, contentId: contentId, frame: expandedCFView!.frame, fileUrl: nil)
		
		var tabHeadModel = TabViewModel(contentId: UUID())
		tabHeadModel.position = expandedCFView!.createNewTab(tabView: niWebView)
		tabHeadModel.webView = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		self.tabs.append(tabHeadModel)
		
		selectTab(at: tabHeadModel.position)
		
		return tabHeadModel.position
	}
	
	func openAndEditEmptyTab(){
		let pos = openEmptyTab()
		//needs to happen a frame later as otherwise the cursor will not jump into the editing mode
		DispatchQueue.main.async {
			self.editTabUrl(at: pos)
		}
	}
	
	func openWebsiteInNewTab(urlStr: String, contentId: UUID, tabName: String, webContentState: String? = nil) -> Int{
		let niWebView = getNewWebView(owner: self, frame: expandedCFView!.frame, dirtyUrl: urlStr, contentId: contentId)
		
		var tabHeadModel = TabViewModel(contentId: contentId)
		tabHeadModel.position = expandedCFView!.createNewTab(tabView: niWebView)
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
		tabs[at].webView?.load(urlReq)
	}
	
	/*
	 * MARK: selecting, closing, editing tabs
	 */
	func closeTab(at: Int){
		if(at != selectedTabModel){
			//open: implement proper methodology to end editing a URL, before closing a tab
			//otherwise we'll run into an index out of bounds issue
		}else {
			updateWVTabHeadPos(from: at+1)
			closeSelectedTab()
		}
	}
	
	private func updateWVTabHeadPos(from: Int){
		var toUpdate = from
		
		while toUpdate < tabs.count{
			tabs[toUpdate].webView?.tabHeadPosition = (toUpdate - 1)
			toUpdate += 1
		}
	}
	
	func closeSelectedTab(){
		if(0 < selectedTabModel){
			let toDeletePos = selectedTabModel
			selectedTabModel -= 1
			
			expandedCFView?.deleteSelectedTab(at: toDeletePos)
			self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
			
			expandedCFView?.cfTabHeadCollection.reloadData()
		}else if( selectedTabModel == 0 && self.tabs.count == 1){
			view.removeFromSuperview()
		}else if( selectedTabModel == 0 && 1 < self.tabs.count){
			let toDeletePos = selectedTabModel
			
			expandedCFView?.deleteSelectedTab(at: toDeletePos)
			self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
			
			expandedCFView?.cfTabHeadCollection.reloadData()
		}
	}
	
	func selectTab(at: Int, mouseDownEvent: NSEvent? = nil){
		
		//No tab switching while CF is not active
		if(!self.expandedCFView!.frameIsActive){
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
		
		forceSelectTab(at: at)
		
		expandedCFView?.cfTabHeadCollection.reloadData()
		expandedCFView?.cfTabHeadCollection.scrollToItems(at: Set(arrayLiteral: IndexPath(item: at, section: 0)), scrollPosition: .nearestVerticalEdge)
	}
	
	/// skipps all checks ensuring UI consistency. Does not reload the TabHead Collection View
	///
	/// Only call this directly, when reloading a space!
	func forceSelectTab(at: Int){
		if(0 <= selectedTabModel){
			tabs[selectedTabModel].isSelected = false
		}
		
		self.expandedCFView?.niContentTabView.selectTabViewItem(at: at)
		self.expandedCFView?.updateFwdBackTint()
		
		self.selectedTabModel = at
		tabs[selectedTabModel].isSelected = true
	}
	
	@MainActor
	func editTabUrl(at: Int){
		self.aTabIsInEditingMode = true
		tabs[at].inEditingMode = true
		expandedCFView?.cfTabHeadCollection.reloadData()
		expandedCFView?.cfTabHeadCollection.scrollToItems(at: Set(arrayLiteral: IndexPath(item: at, section: 0)), scrollPosition: .nearestVerticalEdge)
	}
	
	func endEditingTabUrl(){
		if(!aTabIsInEditingMode){
			return
		}
		endEditingTabUrl(at: selectedTabModel)
	}
	
	func endEditingTabUrl(at: Int){
		self.aTabIsInEditingMode = false
		
		if(at < tabs.count){
			tabs[at].inEditingMode = false
			
			// This update interferes with the (async) web view callback and effectively defaults all editing operations to go to Google
			RunLoop.main.perform { [self] in
				expandedCFView?.cfTabHeadCollection.reloadData()
			}
		}
	}
	
	func setTabIcon(at: Int, icon: NSImage?){
		tabs[at].icon = icon
	}
	
	
	/*
	 * MARK: - keyboard caputure here:
	 */
	override func keyDown(with event: NSEvent) {
		//key responder chain does not get updated properly
		if(!myView.frameIsActive){
			nextResponder?.keyDown(with: event)
			return
		}
		
		if(event.modifierFlags.contains(.command)){
			if(event.keyCode == kVK_ANSI_T){
				openAndEditEmptyTab()
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
		guard let wv = webView as? NiWebView else{return}
		
		wv.retries = 0
		
		self.tabs[wv.tabHeadPosition].title = wv.title ?? ""
		self.tabs[wv.tabHeadPosition].icon = nil
		
		//an empty tab still loads a local html
		if(self.tabs[wv.tabHeadPosition].state != .empty && self.tabs[wv.tabHeadPosition].state != .error ){
			self.tabs[wv.tabHeadPosition].state = .loaded
			if(wv.url != nil){
				self.tabs[wv.tabHeadPosition].url = wv.url!.absoluteString
			}
			expandedCFView?.cfTabHeadCollection.reloadItems(at: Set(arrayLiteral: IndexPath(item: wv.tabHeadPosition, section: 0)))
		}
		
	}
	
	func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error){
		handleFailedLoad(webView)
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error){
		handleFailedLoad(webView)
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if(navigationAction.modifierFlags == .command){
			let urlStr = navigationAction.request.url?.absoluteString
			if(urlStr != nil && !urlStr!.isEmpty){
				self.openWebsiteInNewTab(urlStr!)
				decisionHandler(WKNavigationActionPolicy.cancel)
				return
			}
		}
		decisionHandler(WKNavigationActionPolicy.allow)
	}
	
	//open in new tab, example clicked file in gDrive
	func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?{
		if(navigationAction.targetFrame == nil){
			let urlStr = navigationAction.request.url?.absoluteString
			if(urlStr != nil && !urlStr!.isEmpty){
				self.openWebsiteInNewTab(urlStr!)
			}
		}
		return nil
	}
	
	private func handleFailedLoad(_ webView: WKWebView){
		guard let wv = webView as? NiWebView else{
			let errorURL = getCouldNotLoadWebViewURL()
			webView.loadFileURL(errorURL, allowingReadAccessTo: errorURL.deletingLastPathComponent())
			return
		}
		if (wv.retries < 2){
			wv.reload()
			wv.retries += 1
			return
		}
		let errorURL = getCouldNotLoadWebViewURL()
		webView.loadFileURL(errorURL, allowingReadAccessTo: errorURL.deletingLastPathComponent())
		self.tabs[wv.tabHeadPosition].state = .error
	}
	
	/*
	 * MARK: - Tab Heads collection control functions
	 */
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int{
		expandedCFView?.recalcDragArea(nrOfTabs: self.tabs.count)
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
			return ContentFrameView.DEFAULT_TAB_SIZE
		}
		
		let maxWidth = (expandedCFView?.cfTabHeadCollection.frame.width ?? 780) / 2
		let nrOfCharacters = viewModel.webView?.url?.absoluteString.count ?? 30
		var tabHeadWidth = CGFloat(nrOfCharacters) * 8.0 + 30
		
		if(maxWidth < tabHeadWidth){
			tabHeadWidth = maxWidth
		}
		
		if(tabHeadWidth < ContentFrameView.DEFAULT_TAB_SIZE.width){
			tabHeadWidth = ContentFrameView.DEFAULT_TAB_SIZE.width
		}
		expandedCFView?.recalcDragArea(specialTabWidth: tabHeadWidth)
		
		return NSSize(width: tabHeadWidth, height: 30)
	}
	
	func collectionView(
		_ collectionView: NSCollectionView,
		layout collectionViewLayout: NSCollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int
	) -> CGFloat{
		return ContentFrameView.SPACE_BETWEEN_TABS
	}
	
	/*
	 * MARK: - store and load here
	 */
	
	func persistContent(documentId: UUID){
		for tab in tabs {
			let url = tab.webView?.url?.absoluteString ?? tab.url
			CachedWebTable.upsert(documentId: documentId, id: tab.contentId, title: tab.title, url: url)
		}
	}
	
	func toNiContentFrameModel() -> (model: NiDocumentObjectModel, nrOfTabs: Int, state: NiConentFrameState){
		
		var children: [NiCFTabModel] = []
		
		for (i, tab) in tabs.enumerated(){
			children.append(
				NiCFTabModel(
					id: tab.contentId,
					contentType: NiCFTabContentType.web,
					contentState: tab.state.rawValue,
					active: tab.isSelected,
					position: i
				)
			)
		}
		
		
		//FIXME: this does not work :cry:
		let posInStack = Int(view.layer!.zPosition)
		let model = NiDocumentObjectModel(
			type: NiDocumentObjectTypes.contentFrame,
			data: NiContentFrameModel(
				state: self.viewState,
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
		
		return (model: model, nrOfTabs: children.count, state: self.viewState)
	}
}
