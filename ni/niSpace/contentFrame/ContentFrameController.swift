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
	private(set) var tabs: [TabViewModel] = []
	var viewState: NiConentFrameState = .expanded
		
	private var closeCancelled = false
	private(set) var closeTriggered = false
	
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
		}else if(viewState == .frameless){
			loadAndDisplayFramelessView()
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
	
	private func loadAndDisplayFramelessView(){
		self.view = loadFramelessView()
	}
	
	private func loadFramelessView() -> CFBaseView{
		let framelessView = (NSView.loadFromNib(nibName: "CFFramelessView", owner: self) as! CFFramelessView)
		framelessView.setSelfController(self)
		framelessView.wantsLayer = true
		framelessView.layer?.backgroundColor = NSColor.sandLight3.cgColor
		return framelessView
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
	 * MARK: close Window
	 */
	
	/** triggers close animation and displays undo button
	 
	runs following steps:
	1. fade out current view
	2. display undo button
	   * if clicked "undo button": cancel deletion
	   * if "undo" ignored: clean up and remove this controller plus view from hierarchy
	 */
	func triggerCloseProcess(with event: NSEvent){
		//stops double click, as it will have unwanted side effects
		if(closeTriggered){
			return
		}
		fadeout()
		loadAndDisplaySoftDeletedView(topRightCorner: CGPoint(x: view.frame.maxX, y: view.frame.minY))
		closeTriggered = true
	}
	
	private func loadAndDisplaySoftDeletedView(topRightCorner: CGPoint) {
		let softDeletedView = (NSView.loadFromNib(nibName: "CFSoftDeletedView", owner: self) as! CFSoftDeletedView)
		softDeletedView.setSelfController(self)
		softDeletedView.initAfterViewLoad()
		
		var undoOrigin = topRightCorner
		undoOrigin.x = undoOrigin.x - softDeletedView.frame.width
		softDeletedView.frame.origin = undoOrigin
		softDeletedView.layer?.zPosition = self.view.layer!.zPosition
		self.view.superview?.addSubview(softDeletedView)
	}
	
	private func fadeout(){
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.5
			self.view.animator().alphaValue = 0.0
		}, completionHandler: {
			if(self.closeCancelled || !self.closeTriggered){
				return
			}
			self.view.isHidden = true
			self.view.alphaValue = 1.0
		})
	}
	
	func cancelCloseProcess(){
		self.closeCancelled = true
		self.closeTriggered = false
		fadeIn()
	}
	
	private func fadeIn(){
		self.view.isHidden = false
		self.view.alphaValue = 1.0
	}
	
	func confirmClose(){
		if(self.closeCancelled){
			self.closeCancelled = false
			self.closeTriggered = false
			return
		}
		myView.closedContentFrameCleanUp()
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
	func minimizeSelf(){
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
	
	func minimizedToExpanded(_ shallSelectTabAt: Int = -1){
		//We need to clear the data here, otherwise we'll produce a faulty TabHeadCollection
		if( 0 <= shallSelectTabAt){
			for (i, _) in tabs.enumerated(){
				tabs[i].isSelected = false
			}
		}
		var tabSelectedInModel: Int = 0
		
		if(expandedCFView == nil){
			tabSelectedInModel = recreateExpandedCFView()
			expandedCFView?.setFrameOwner(self.myView.niParentDoc)
		}
		//position
		//TODO: ensure it's not out of bounds?
		expandedCFView!.frame.origin.y = self.view.frame.origin.y
		
		var newXorigin = self.view.frame.origin.x + self.view.frame.width - expandedCFView!.frame.width
		if(newXorigin < 0){
			newXorigin = self.view.frame.origin.x
		}
		expandedCFView!.frame.origin.x = newXorigin
		if(self.view.layer != nil){
			expandedCFView!.layer?.zPosition = self.view.layer!.zPosition
		}
		
		//replace
		self.view.superview?.replaceSubview(self.view, with: expandedCFView!)
		self.view = expandedCFView!
		
		self.viewState = .expanded
		if(0 <= shallSelectTabAt){
			forceSelectTab(at: shallSelectTabAt)
		}else{
			forceSelectTab(at: tabSelectedInModel)
		}
		
		self.expandedCFView!.niParentDoc?.setTopNiFrame(self)
		
		sharedLoadViewSetters()
	}
	
	func recreateExpandedCFView() -> Int {
		loadExpandedView()
		var selectedTabPos: Int = 0
		
		for i in tabs.indices{
			let wview = getNewWebView(owner: self, frame: expandedCFView!.frame ,cleanUrl: tabs[i].content, contentId: tabs[i].contentId)
			tabs[i].view = wview
			tabs[i].position = expandedCFView!.createNewTab(tabView: wview)
			wview.tabHeadPosition = tabs[i].position
			if(tabs[i].isSelected){
				selectedTabPos = i
			}
		}
		return selectedTabPos
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
					tabs[i].content = tabs[i].webView!.url!.absoluteString
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
	func openEmptyWebTab(_ contentId: UUID = UUID()) -> Int{
		let niWebView = ni.getNewWebView(owner: self, contentId: contentId, frame: expandedCFView!.frame, fileUrl: nil)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .web)
		tabHeadModel.position = expandedCFView!.createNewTab(tabView: niWebView)
		tabHeadModel.view = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		self.tabs.append(tabHeadModel)
		
		selectTab(at: tabHeadModel.position)
		
		return tabHeadModel.position
	}
	
	func openAndEditEmptyWebTab(){
		if(viewState == .minimised || viewState == .frameless){
			__NSBeep()
			return
		}
		
		let pos = openEmptyWebTab()
		//needs to happen a frame later as otherwise the cursor will not jump into the editing mode
		DispatchQueue.main.async {
			self.editTabUrl(at: pos)
		}
	}
	
	func openNoteInNewTab(contentId: UUID = UUID(), tabTitle: String? = nil, content: String? = nil){
		let noteView = ni.getNewNoteView(owner: self, parentView: self.view, frame: self.view.frame)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .note, isSelected: true)
		tabHeadModel.position = 0
		tabHeadModel.view = noteView
		self.tabs.append(tabHeadModel)
		
		_ = myView.createNewTab(tabView: noteView)
		myView.window?.makeFirstResponder(noteView)
		noteView.string = content ?? ""
	}
	
	func openWebsiteInNewTab(urlStr: String, contentId: UUID, tabName: String, webContentState: TabViewModelState? = nil, openNextTo: Int = -1) -> Int{
		let niWebView = getNewWebView(owner: self, frame: expandedCFView!.frame, dirtyUrl: urlStr, contentId: contentId)
		let viewPosition = expandedCFView!.createNewTab(tabView: niWebView, openNextTo: openNextTo)
		
		if(0 <= openNextTo){
			updateWVTabHeadPos(from: viewPosition, moveLeft: false)
		}
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .web)
		tabHeadModel.position = viewPosition
		tabHeadModel.view = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		if(webContentState != nil){
			tabHeadModel.state = webContentState!
		}else{
			tabHeadModel.state = .loading
		}
		
		if(0 <= openNextTo){
			self.tabs.insert(tabHeadModel, at: viewPosition)
		}else{
			self.tabs.append(tabHeadModel)
		}
		
		return tabHeadModel.position
    }
	
	func openWebsiteInNewTab(_ urlStr: String, shallSelectTab: Bool = true, openNextToSelectedTab: Bool = false){
        let id = UUID()
		let pos = if(openNextToSelectedTab){
			openWebsiteInNewTab(urlStr: urlStr, contentId: id, tabName: "", openNextTo: selectedTabModel)
		}else{
			openWebsiteInNewTab(urlStr: urlStr, contentId: id, tabName: "")
		}
		
		if(shallSelectTab){
			selectTab(at: pos)
		}else{
			expandedCFView?.cfTabHeadCollection.reloadData()
			expandedCFView?.cfTabHeadCollection.scrollToItems(at: Set(arrayLiteral: IndexPath(item: pos, section: 0)), scrollPosition: .nearestVerticalEdge)
		}
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
			closeSelectedTab()
		}
	}
	
	private func updateWVTabHeadPos(from: Int, moveLeft: Bool = true){
		var toUpdate = from
		
		while toUpdate < tabs.count{
			if(moveLeft){
				tabs[toUpdate].position = (toUpdate - 1)
				tabs[toUpdate].webView?.tabHeadPosition = (toUpdate - 1)
			}else{
				tabs[toUpdate].position = (toUpdate + 1)
				tabs[toUpdate].webView?.tabHeadPosition = (toUpdate + 1)
			}
			toUpdate += 1
		}
	}
	
	func closeSelectedTab(){
		if(viewState != .expanded){
			return
		}
		
		updateWVTabHeadPos(from: selectedTabModel+1)
		var deletedTabModel: TabViewModel?
		
		if(0 < selectedTabModel){
			let toDeletePos = selectedTabModel
			selectedTabModel -= 1
			
			expandedCFView?.deleteSelectedTab(at: toDeletePos)
			deletedTabModel = self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
			
			expandedCFView?.cfTabHeadCollection.reloadData()
		}else if( selectedTabModel == 0 && self.tabs.count == 1){
			deletedTabModel = self.tabs.remove(at: selectedTabModel)
			
			myView.niParentDoc?.removeNiFrame(self)
			view.removeFromSuperview()
		}else if( selectedTabModel == 0 && 1 < self.tabs.count){
			let toDeletePos = selectedTabModel
			
			expandedCFView?.deleteSelectedTab(at: toDeletePos)
			deletedTabModel = self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
			
			expandedCFView?.cfTabHeadCollection.reloadData()
		}
		
		if(deletedTabModel != nil){
			ContentTable.delete(id: deletedTabModel!.contentId)
		}

		deletedTabModel?.view = nil
	}
	
	func selectNextTab(goFwd: Bool = true){
		var nxtTab: Int = if(goFwd){
			self.selectedTabModel + 1
		}else{
			self.selectedTabModel - 1
		}
		
		// cycles to first and last tab...
		if(nxtTab < 0){
			nxtTab = self.tabs.count - 1
		}
		
		if((self.tabs.count - 1) < nxtTab){
			nxtTab = 0
		}
		selectTab(at: nxtTab)
	}
	
	func selectTab(at: Int, mouseDownEvent: NSEvent? = nil){
		
		//No tab switching while CF is not active
		if(self.expandedCFView == nil || !self.expandedCFView!.frameIsActive){
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
	
	func toggleEditSelectedTab(){
		if(self.viewState == .minimised){
			__NSBeep()
			return
		}
		if(aTabIsInEditingMode){
			endEditingTabUrl()
		}else{
			editTabUrl(at: selectedTabModel)
		}
	}
	
	@MainActor
	func editTabUrl(at: Int){
		if(at < 0){
			__NSBeep()
			return
		}
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
		//We need this check due to the async nature of setting tabIcons.
		//It may be that the tab is already closed by the time we fetched the icon
		if(at < tabs.count && 0 <= at){
			tabs[at].icon = icon
		}
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
				openAndEditEmptyWebTab()
				return
			}else if(event.keyCode == kVK_ANSI_W){
				closeSelectedTab()
				return
			}
		}
		
		if(event.modifierFlags.contains(.control)){
			if(event.keyCode == kVK_Tab && event.modifierFlags.contains(.shift)){
				selectNextTab(goFwd: false)
				return
			}
			if(event.keyCode == kVK_Tab){
				selectNextTab()
				return
			}
		}
		
		nextResponder?.keyDown(with: event)
	}
	
	@IBAction func switchToNextTab(_ sender: NSMenuItem) {
		selectNextTab()
	}
	
	@IBAction func switchToPrevTab(_ sender: NSMenuItem) {
		selectNextTab(goFwd: false)
	}
	
	/*
	 * MARK: - WKDelegate functions
	 */
	func webView(_ webView: WKWebView, didFinish: WKNavigation!){
		guard let wv = webView as? NiWebView else{return}
		
		//check if tab was closed by the time this callback happens
		if(tabs.count <= wv.tabHeadPosition || tabs[wv.tabHeadPosition].webView != wv){
			return
		}
		
		wv.retries = 0
		
		self.tabs[wv.tabHeadPosition].title = wv.title ?? ""
		self.tabs[wv.tabHeadPosition].icon = nil
		
		//an empty tab still loads a local html
		if(self.tabs[wv.tabHeadPosition].state != .empty && self.tabs[wv.tabHeadPosition].state != .error ){
			self.tabs[wv.tabHeadPosition].state = .loaded
			if(wv.url != nil){
				self.tabs[wv.tabHeadPosition].content = wv.url!.absoluteString
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
		
		//open in new tab, comand clicked on link
		if(navigationAction.modifierFlags == .command){
			let urlStr = navigationAction.request.url?.absoluteString
			if(urlStr != nil && !urlStr!.isEmpty){
				self.openWebsiteInNewTab(urlStr!, shallSelectTab: false, openNextToSelectedTab: true)
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
				self.openWebsiteInNewTab(urlStr!, openNextToSelectedTab: true)
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
	
	func purgePersistetContent(){
		for tab in tabs {
			ContentTable.delete(id: tab.contentId)
		}
	}
	
	func persistContent(documentId: UUID){
		if(closeTriggered){
			return
		}
		for tab in tabs {
			if(tab.type == .web){
				//TODO: add guard rails to not enter empty tab
				let url = tab.webView?.url?.absoluteString ?? tab.content
				CachedWebTable.upsert(documentId: documentId, id: tab.contentId, title: tab.title, url: url)
			}
			if(tab.type == .note){
				let txt = tab.noteView?.getText()
				let title = tab.noteView?.getTitle()
				if(txt != nil){
					NoteTable.upsert(documentId: documentId, id: tab.contentId, title: title, rawText: txt!)
				}
			}
		}
	}
	
	func toNiContentFrameModel() -> (model: NiDocumentObjectModel?, nrOfTabs: Int, state: NiConentFrameState?){
		
		//do nothing, as we are in the deletion process
		if(closeTriggered){
			purgePersistetContent()
			return (model: nil,  nrOfTabs: 0, state: nil)
		}
		
		var children: [NiCFTabModel] = []
		
		for (i, tab) in tabs.enumerated(){
			if(tab.type == .web
			   || (tab.type == .note && tab.noteView?.getText() != nil)
			){
				children.append(
					NiCFTabModel(
						id: tab.contentId,
						contentType: tab.type,
						contentState: tab.state.rawValue,
						active: tab.isSelected,
						position: i
					)
				)
			}
		}
		
		if(children.isEmpty){
			return (model: nil,  nrOfTabs: 0, state: nil)
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
