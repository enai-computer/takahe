
//
//  ContentFrameController.swift
//  ni
//
//  Created by Patrick Lukas on 12/3/23.
//

import Foundation
import Cocoa
import Carbon.HIToolbox
@preconcurrency import WebKit
import PDFKit
import QuartzCore
import FaviconFinder
import PostHog

//TODO: clean up tech debt and move the delegates out of here
class ContentFrameController: NSViewController, WKNavigationDelegate, WKUIDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout{

	var myView: CFBaseView {return self.view as! CFBaseView}
	var framelessView: CFFramelessView? {return self.view as? CFFramelessView}
	var simpleFrame: CFSimpleFrameView? {return self.view as? CFSimpleFrameView}
	var viewWithTabs: CFTabHeadProtocol? {return self.view as? CFTabHeadProtocol}
	
	private(set) var expandedCFView: ContentFrameView? = nil
	private var selectedTabModel: Int = -1
	//we need this var to have the behaviour that tabs that get open with cmd+click open in sequence next to each other
	//and not just right next to the current tab
	private var nxtTabPosOpenNxtTo: Int? = nil
	private(set) var aTabIsInEditingMode: Bool = false
	private(set) var tabs: [TabViewModel] = []
	var viewState: NiConentFrameState = .expanded
	private var viewIsDrawn = false
	
	private var closeCancelled = false
	private(set) var closeTriggered = false
	
	private var groupName: String?
	private var groupId: UUID?
	private var prevDisplayState: NiPreviousDisplayState?
	
	/*
	 * MARK: init & view loading here
	 */
	init(viewState: NiConentFrameState, 
		 groupName: String?,
		 groupId: UUID?,
		 tabsModel: [TabViewModel]? = nil,
		 previousDisplayState: NiPreviousDisplayState? = nil
	){
		self.viewState = viewState
		self.groupName = groupName
		self.groupId = groupId
		if(tabsModel != nil){
			self.tabs = tabsModel!
		}
		self.prevDisplayState = previousDisplayState
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		switch(viewState){
			case .minimised:
				loadAndDisplayMinimizedView()
				return
			case .collapsedMinimised:
				loadAndDisplayCollapsedMinimizedView()
				return
			case .simpleMinimised:
				loadAndDisplaySimpleMinimizedView()
				return
			case .frameless:
				loadAndDisplayFramelessView()
				return
			case .simpleFrame:
				loadAndDisplaySimpleFrameView()
				return
			case .fullscreen:
				loadAndDisplayFullscreenView()
				return
			default:
				loadAndDisplayDefaultView()
		}
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		viewIsDrawn = true
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		viewIsDrawn = false
	}
	
	private func loadAndDisplayDefaultView(){
		loadExpandedView()
		self.view = expandedCFView!
		sharedLoadViewSetters()
	}
	
	private func loadExpandedView(){
		self.expandedCFView = (NSView.loadFromNib(nibName: "ContentFrameView", owner: self) as! ContentFrameView)
		self.expandedCFView?.setSelfController(self)
		self.expandedCFView?.initAfterViewLoad(groupName)
		
		expandedCFView!.cfHeadView.wantsLayer = true
		expandedCFView!.cfHeadView.layer?.backgroundColor = NSColor(.sand4).cgColor
	}
	
	private func loadAndDisplayFullscreenView(){
		self.view = loadFullscreenView()
	}
	
	private func loadFullscreenView() -> CFFullscreenView{
		groupName = expandedCFView?.cfGroupButton.getName() ?? groupName
		
		let fullscreenView = (NSView.loadFromNib(nibName: "CFFullscreenView", owner: self) as! CFFullscreenView)
		fullscreenView.setSelfController(self)
		fullscreenView.wantsLayer = true
		
		let spaceName = (NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController()?.getCurrentSpaceName() ?? ""
		fullscreenView.initAfterViewLoad(spaceName: spaceName, groupName: groupName)
		
		return fullscreenView
	}
	
	private func loadAndDisplayFramelessView(){
		self.view = loadFramelessView()
	}
	
	private func loadFramelessView() -> CFBaseView{
		let framelessView = (NSView.loadFromNib(nibName: "CFFramelessView", owner: self) as! CFFramelessView)
		framelessView.setSelfController(self)
		framelessView.wantsLayer = true
		framelessView.layer?.cornerRadius = 5.0
		framelessView.layer?.cornerCurve = .continuous
		framelessView.layer?.backgroundColor = NSColor.sand3.cgColor
		return framelessView
	}
	
	private func loadAndDisplaySimpleFrameView(){
		let simpleFrameView = loadSimpleFrameView()
		self.view = simpleFrameView
		self.viewState = .simpleFrame
	}
	
	private func loadSimpleFrameView() -> CFSimpleFrameView{
		let simpleFrameView = (NSView.loadFromNib(nibName: "CFSimpleFrameView", owner: self) as! CFSimpleFrameView)
		simpleFrameView.setSelfController(self)
		simpleFrameView.initAfterViewLoad(groupName,
										  titleChangedCallback: simpleViewTitleChangedCallback)
		simpleFrameView.wantsLayer = true
		simpleFrameView.layer?.cornerRadius = 10.0
		simpleFrameView.layer?.cornerCurve = .continuous
		simpleFrameView.layer?.backgroundColor = NSColor.sand3.cgColor
		return simpleFrameView
	}
	
	/** only use this in views with one tab.
	 
	 The tabGroup title reflects the document name. These need to be kept in sync in case the single tab is moved into a group.
	 */
	func simpleViewTitleChangedCallback(_ newTitle: String){
		guard !newTitle.isEmpty && newTitle != "/" else {return}
		tabs[0].title = newTitle
	}
	
	private func loadAndDisplaySimpleMinimizedView(){
		let simpleMinimizedView = loadSimpleMinimzedView()
		self.view = simpleMinimizedView
		self.viewState = .simpleMinimised
	}
	
	private func loadSimpleMinimzedView() -> CFSimpleMinimizedView{
		let simpleMinimizedView = (NSView.loadFromNib(nibName: "CFSimpleMinimizedView", owner: self) as! CFSimpleMinimizedView)
		if(0 < tabs.count){
			simpleMinimizedView.initAfterViewLoad(tab: tabs[0])
		}
		simpleMinimizedView.setSelfController(self)
		return simpleMinimizedView
	}
	
	private func loadAndDisplayMinimizedView(){
		let minimizedView = loadMinimizedView()
		minimizedView.cfGroupButton.setView(title: groupName)
		self.view = minimizedView
		self.viewState = .minimised
		
		sharedLoadViewSetters()
	}
	
	private func loadAndDisplayCollapsedMinimizedView(){
		let collapsedMinimized = loadCollapsedMinizedView()
		self.view = collapsedMinimized
		self.viewState = .collapsedMinimised
		
		sharedLoadViewSetters()
	}
	
	private func loadMinimizedView() -> CFMinimizedView{
		let minimizedView = (NSView.loadFromNib(nibName: "CFMinimizedView", owner: self) as! CFMinimizedView)
		
		//if loaded when space is generated from storage this value will be overwritten
		minimizedView.setSelfController(self)
		
		let stackItems = genMinimizedStackItems(tabs: tabs, owner: self)
		minimizedView.listOfTabs?.setViews(stackItems, in: .top)

		//FIXME: clean up tech debt and do some binding here
		groupName = expandedCFView?.cfGroupButton.getName() ?? groupName
		minimizedView.initAfterViewLoad(nrOfItems: stackItems.count, groupName: groupName)
		return minimizedView
	}
	
	private func loadCollapsedMinizedView() -> CFCollapsedMinimizedView{
		let collapsedMinimizedView = (NSView.loadFromNib(nibName: "CFCollapsedMinimizedView", owner: self) as! CFCollapsedMinimizedView)
		
		collapsedMinimizedView.setSelfController(self)
		
		let stackItems = genCollapsedMinimzedStackItems(
			tabs: tabs,
			handler: collapsedMinimizedView)
		collapsedMinimizedView.listOfTabs?.setViews(stackItems, in: .center)
		
		groupName = expandedCFView?.cfGroupButton.getName() ?? groupName
		collapsedMinimizedView.initAfterViewLoad(nrOfItems: tabs.count, groupName: groupName)
		
		return collapsedMinimizedView
	}
	
	private func sharedLoadViewSetters(){
		self.view.wantsLayer = true
		self.view.layer?.cornerRadius = 10
		self.view.layer?.cornerCurve = .continuous
		self.view.layer?.borderWidth = 5
		self.view.layer?.borderColor = NSColor(.sand4).cgColor
		self.view.layer?.backgroundColor = NSColor(.sand4).cgColor
	}
	
	func tryPrintContent(_ sender: Any?){
		if(selectedTabModel < 0 && 0 < tabs.count){
			tabs[0].viewItem?.printView(sender)
			return
		}
		if(selectedTabModel < tabs.count && 0 <= selectedTabModel){
			tabs[selectedTabModel].viewItem?.printView(sender)
			return
		}
	}
	
	/*
	 * MARK: drop down menu
	 */
	func showDropdown(with event: NSEvent){
		loadAndDisplayDropdownMenu()
	}
	
	private func loadAndDisplayDropdownMenu(){
		var editNameItem: NiMenuItemViewModel? = nil
		var optionalMenuItem: NiMenuItemViewModel? = nil
		if(viewState == .expanded){
			editNameItem = expandedCFView!.cfGroupButton.getNameTileMenuItem()
			optionalMenuItem = expandedCFView!.cfGroupButton.getRemoveTitleMenuItem()
		}else if(viewState == .minimised || viewState == .collapsedMinimised){
			let minimizedView = self.view as! CFHasGroupButtonProtocol
			editNameItem = minimizedView.cfGroupButton.getNameTileMenuItem()
			optionalMenuItem = minimizedView.cfGroupButton.getRemoveTitleMenuItem()
		}else if(viewState == .simpleFrame){
			let simpleFrameView = self.view as! CFSimpleFrameView
			editNameItem = simpleFrameView.cfGroupButton.getNameTileMenuItem()
		}
		
		let items = [ editNameItem, optionalMenuItem,
			NiMenuItemViewModel(title: "Pin to the menu (soon)", isEnabled: false, mouseDownFunction: nil),
			NiMenuItemViewModel(title: "Move to another space (soon)", isEnabled: false, mouseDownFunction: nil)
		]
		let (menuOrigin, popsDownwards) = positionDropdownMenu(NiMenuWindow.calcSize(items.count).height)
		let menuWin = NiMenuWindow(
			origin: menuOrigin,
			dirtyMenuItems: items,
			currentScreen: view.window!.screen!,
			adjustOrigin: popsDownwards
		)
		menuWin.makeKeyAndOrderFront(nil)
	}
	
	private func positionDropdownMenu(_ predictedHight: CGFloat) -> (NSPoint, Bool) {
		if(viewState == .expanded){
			if let refernceView = expandedCFView {
				let pInView = NSPoint(
					x: refernceView.cfHeadView.frame.origin.x + (refernceView.cfGroupButton.frame.origin.x),
					y: refernceView.cfHeadView.frame.origin.y + 16.0)
				return (self.view.convert(pInView, to: view.window?.contentView), true)
			}
		}else if(viewState == .minimised || viewState == .collapsedMinimised){
			var pInView = view.frame.origin
			pInView.x -= 7.0
			pInView.y += 13.0
			let globalPointUp = self.view.superview!.convert(pInView, to: view.window?.contentView)
			
			//pops up out of bounds/ opens downwards
			if(view.superview!.visibleRect.maxY < (globalPointUp.y + predictedHight)){
				pInView = view.frame.origin
				pInView.y += 30.0
				return (self.view.superview!.convert(pInView, to: view.window?.contentView), true)
			}else{
				return (globalPointUp, false)
			}
		}else if(viewState == .simpleFrame){
			if let refernceView = self.view as? CFSimpleFrameView {
				let pInView = NSPoint(
					x: refernceView.cfHeadView.frame.origin.x + (refernceView.cfGroupButton.frame.origin.x),
					y: refernceView.cfHeadView.frame.origin.y + 16.0)
				return (self.view.convert(pInView, to: view.window?.contentView), true)
			}
		}
		
		return (NSPoint(x: 0.0, y: 0.0), false)
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
		if(1 == tabs.count){
			softDeletedView.initAfterViewLoad(tabs[0].type.toDescriptiveName())
		}else{
			softDeletedView.initAfterViewLoad()
		}
		
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
		removeFromParent()
		if(viewState == .fullscreen){
			if let spaceController = (NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController(){
				spaceController.showHeader()
			}
		}
	}
	
	/*
	 * MARK: passToView Functions
	 */
	func toggleActive(){
		myView.toggleActive()
	}
	
	func reloadSelectedTab(){
		if(viewState != .minimised){
			if(selectedTabModel < 0 && 0 < tabs.count){
				tabs[0].webView?.reload()
			}else if(0 < tabs.count){
				tabs[selectedTabModel].webView?.reload()
			}
		}
	}
	
	/*
	 * MARK: minimizing, expanding and maximizing
	 */
	func minimizeSelf(){
		if(viewState == .expanded && (prevDisplayState == nil || prevDisplayState?.state == .minimised)){
			minimizeSelfToDefault()
		}else if(viewState == .expanded
				 && prevDisplayState != nil
				 && prevDisplayState!.state == .collapsedMinimised){
			minimizeToCollapsed()
		}
		else if(viewState == .simpleFrame){
			minimizeSelfToSimple()
		}
	}
	
	func minimizeClicked(_ event: NSEvent) {
		minimizeSelf()
	}
	
	private func minimizeSelfToDefault(){
		updateTabViewModel()
		let minimizedView = loadMinimizedView()
		minimizedView.setFrameOwner(myView.niParentDoc)
		positionMinimizedView(for: minimizedView)
		
		prevDisplayState = nil
		
		//replace
		self.view.superview?.replaceSubview(self.view, with: minimizedView)
		self.view = minimizedView
		self.viewState = .minimised
		
		self.myView.niParentDoc?.setTopNiFrame(self)
		sharedLoadViewSetters()
	}
	
	private func minimizeSelfToSimple(){
		let simpleMinimizedView = loadSimpleMinimzedView()
		simpleMinimizedView.setFrameOwner(myView.niParentDoc)
		
		positionMinimizedView(for: simpleMinimizedView)
		//replace
		if let zPos = self.view.layer?.zPosition{
			simpleMinimizedView.layer?.zPosition = zPos
		}
		let oldView = self.myView
		self.view.superview?.replaceSubview(self.view,
											with: simpleMinimizedView)
		self.view = simpleMinimizedView
		self.myView.niParentDoc?.setTopNiFrame(self)
		
		self.viewState = .simpleMinimised
		
		oldView.deinitSelf()
	}
	
	private func positionMinimizedView(for minimizedView: CFBaseView){
		minimizedView.frame.origin.y = self.view.frame.origin.y
		minimizedView.frame.origin.x = self.view.frame.origin.x + self.view.frame.width - minimizedView.frame.width
		
		if let niDocWidth: CGFloat = self.myView.niParentDoc?.frame.width{
			if(niDocWidth < (minimizedView.frame.origin.x + minimizedView.frame.width)){
				minimizedView.frame.origin.x = niDocWidth - minimizedView.frame.width - CFBaseView.CFConstants.defaultMargin
			}
		}

		if(self.view.layer != nil){
			minimizedView.layer?.zPosition = self.view.layer!.zPosition
		}
	}
	
	func maximizeClicked(_ event: NSEvent){
		maximizeSelf()
	}
	
	func makeFullscreenClicked(_ event: NSEvent){
		if(viewState == .expanded){
			expandedToFullscreen()
		}
	}
	
	func expandedToFullscreen(){
		let fullscreenView = loadFullscreenView()
		fullscreenView.setFrameOwner(myView.niParentDoc)
		
		let selectedItem = expandedCFView?.niContentTabView.selectedTabViewItem
		fullscreenView.niContentTabView.tabViewItems = expandedCFView?.niContentTabView.tabViewItems ?? []
		fullscreenView.niContentTabView.selectTabViewItem(selectedItem)
		
		if let zPos = self.view.layer?.zPosition{
			fullscreenView.layer?.zPosition = zPos
		}
		fullscreenView.fillView(with: nil)
		
		self.view.superview?.replaceSubview(self.view, with: fullscreenView)
		self.view = fullscreenView
		self.viewState = .fullscreen
		
		(NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController()?.hideHeader()
		
		self.myView.niParentDoc?.setTopNiFrame(self)
	}
	
	func fullscreenToExpanded(){
		var reloadTabHeads = false
		if(expandedCFView == nil){
			loadExpandedView()
			expandedCFView?.setFrameOwner(self.myView.niParentDoc)
			expandedCFView?.cfGroupButton.setView(title: groupName)
		}else{
			reloadTabHeads = true
		}
		
		if(expandedCFView!.frame.origin.y < 50.0){
			expandedCFView?.frame.origin.y = 50.0
		}
		if(expandedCFView!.frame.origin.x < 50.0){
			expandedCFView?.frame.origin.x = 50.0
		}
		if let zPos = self.view.layer?.zPosition{
			expandedCFView?.layer?.zPosition = zPos
		}
		
		if let fullscreenView = self.view as? CFFullscreenView{
			let selectedItem = fullscreenView.niContentTabView.selectedTabViewItem
			expandedCFView?.niContentTabView.tabViewItems = fullscreenView.niContentTabView.tabViewItems
			
			expandedCFView?.niContentTabView.selectTabViewItem(selectedItem)
		}
		
		//replace
		self.view.superview?.replaceSubview(self.view, with: expandedCFView!)
		self.view = expandedCFView!
		
		self.viewState = .expanded
		self.expandedCFView!.niParentDoc?.setTopNiFrame(self)
		sharedLoadViewSetters()
		
		//ensure visibility
		if let docController: NiSpaceDocumentController = myView.niParentDoc?.nextResponder as? NiSpaceDocumentController{
			view.frame.origin = docController.calculateContentFrameOrigin(for: view.frame, ignoreLeastRecentlyUsed: true)
		}
		
		(NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController()?.showHeader()
		
		if(reloadTabHeads){
			viewWithTabs?.cfTabHeadCollection?.reloadData()
		}
	}
	
	func maximizeSelf(){
		if(viewState == .minimised || viewState == .collapsedMinimised){
			minimizedToExpanded()
		}else if(viewState == .simpleMinimised){
			simpleMinimizedToSimpleFrame()
		}
	}
	
	func minimizedToExpanded(_ shallSelectTabAt: Int = -1){
		
		if let minimizedView = self.view as? CFHasGroupButtonProtocol{
			groupName = minimizedView.cfGroupButton.getName()
		}
		
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
		positionBiggerView(for: expandedCFView!)
		
		prevDisplayState = NiPreviousDisplayState(
			state: viewState,
			expandCollapseDirection: .leftToRight
		)
		
		//replace
		self.view.superview?.replaceSubview(self.view, with: expandedCFView!)
		self.myView.deinitSelf()
		self.view = expandedCFView!
		self.viewState = .expanded
		
		expandedCFView?.cfGroupButton.setView(title: groupName)
		
		if(0 <= shallSelectTabAt){
			forceSelectTab(at: shallSelectTabAt)
		}else{
			forceSelectTab(at: tabSelectedInModel)
		}
		
		self.expandedCFView!.niParentDoc?.setTopNiFrame(self)
		
		sharedLoadViewSetters()
	}
	
	func minimizeToCollapsed(){
		updateTabViewModel()
		if let oldView = self.view as? CFHasGroupButtonProtocol{
			groupName = oldView.cfGroupButton.getName()
		}
		let collapsedView = loadCollapsedMinizedView()
		positionMinimizedView(for: collapsedView)
		collapsedView.setFrameOwner(myView.niParentDoc)
		
		prevDisplayState = nil
		
		//replace
		self.view.superview?.replaceSubview(self.view, with: collapsedView)
		self.view = collapsedView
		self.viewState = .collapsedMinimised
		
		self.myView.niParentDoc?.setTopNiFrame(self)
		sharedLoadViewSetters()
	}
	
	func collapsedToMinimized(){
		if let viewWithName = view as? CFHasGroupButtonProtocol{
			groupName = viewWithName.cfGroupButton.getName()
		}
		let minimizedView = loadMinimizedView()
		positionMinimizedView(for: minimizedView)
		minimizedView.setFrameOwner(myView.niParentDoc)
		
		self.view.superview?.replaceSubview(self.view, with: minimizedView)
		self.view = minimizedView
		self.viewState = .minimised
		
		self.myView.niParentDoc?.setTopNiFrame(self)
		sharedLoadViewSetters()
	}
	
	private func simpleMinimizedToSimpleFrame(){
		let simpleFrameView = loadSimpleFrameView()
		simpleFrameView.setFrameOwner(myView.niParentDoc)
		if(tabs[0].viewItem == nil){
			guard tabs[0].type == .pdf else {fatalError("transition from SimpleMinimizedView to SimpleView for \(tabs[0].type) has not been implemented.")}
			
			tabs[0].viewItem = getNewPdfView(owner: self, frame: simpleFrameView.frame, document: tabs[0].data as! PDFDocument)
		}
		simpleFrameView.createNewTab(tabView: tabs[0].viewItem as! NSView)
		positionBiggerView(for: simpleFrameView)
		if let zPos = self.view.layer?.zPosition{
			simpleFrameView.layer?.zPosition = zPos
		}
		let oldView = self.myView
		self.view.superview?.replaceSubview(self.view, with: simpleFrameView)
		self.view = simpleFrameView
		self.viewState = .simpleFrame
		self.myView.niParentDoc?.setTopNiFrame(self)
		
		oldView.deinitSelf()
	}
	
	/**
	 used to position expanded and simpleFrame views, after clicking the maximizeButton in their minimized Versions
	 */
	private func positionBiggerView(for biggerView: CFBaseView){
		//TODO: ensure it's not out of bounds?
		biggerView.frame.origin.y = self.view.frame.origin.y
		
		if(myView.niParentDoc!.frame.width < biggerView.frame.width){
			biggerView.frame.size.width = myView.niParentDoc!.frame.width - (CFBaseView.CFConstants.defaultMargin * 2.0)
		}
		var newXorigin = self.view.frame.origin.x + self.view.frame.width - biggerView.frame.width
		if(newXorigin < 0){
			newXorigin = self.view.frame.origin.x
		}
		if(myView.niParentDoc!.frame.width < (newXorigin + biggerView.frame.width)){
			newXorigin = myView.niParentDoc!.frame.width - biggerView.frame.width - CFBaseView.CFConstants.defaultMargin
		}
		biggerView.frame.origin.x = newXorigin
		if(self.view.layer != nil){
			biggerView.layer?.zPosition = self.view.layer!.zPosition
		}
	}
	
	func recreateExpandedCFView() -> Int {
		loadExpandedView()
		var selectedTabPos: Int = 0
		
		for i in tabs.indices{
			let wview = getNewWebView(owner: self, frame: expandedCFView!.frame ,cleanUrl: tabs[i].content, contentId: tabs[i].contentId)
			tabs[i].viewItem = wview
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
				tabs[i].title = tabs[i].webView!.getTitle() ?? tabs[i].title
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
	func openEmptyWebTab(_ contentId: UUID = UUID(), reloadTabHeads: Bool = true) -> Int{
		let niWebView = ni.getNewWebView(owner: self, contentId: contentId, frame: view.frame, fileUrl: nil)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .web)
		tabHeadModel.position = myView.createNewTab(tabView: niWebView)
		tabHeadModel.viewItem = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		self.tabs.append(tabHeadModel)
		
		selectTab(at: tabHeadModel.position, reloadTabHeads: reloadTabHeads)
		
		return tabHeadModel.position
	}
	
	func openAndEditEmptyWebTab(){
		if(!viewHasTabs()){
			return
		}
		
		let pos = openEmptyWebTab(reloadTabHeads: false)
		//needs to happen a frame later as otherwise the cursor will not jump into the editing mode
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
			self.editTabUrl(at: pos)
		}
	}
	
	func openPdfInNewTab(contentId: UUID = UUID(), tabTitle: String? = nil, content: PDFDocument, source: String? = nil, scrollTo pageNr: Int? = nil){
		let pdfView = ni.getNewPdfView(owner: self, frame: self.view.frame, document: content)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .pdf, source: source, data: content, isSelected: true)
		if let title = tabTitle{
			tabHeadModel.title = title
		}
		tabHeadModel.position = 0
		tabHeadModel.viewItem = pdfView
		self.tabs.append(tabHeadModel)
		
		_ = myView.createNewTab(tabView: pdfView)
		tabHeadModel.state = .loaded
		asyncSrollPdfToPage(pdfView, pageNr)
	}
	
	private func asyncSrollPdfToPage(_ pdfView: NiPdfView, _ pageNr: Int?){
		if(pageNr != nil){
			DispatchQueue.main.async {
				if let gotoPage = pdfView.document?.page(at: pageNr!){
					pdfView.go(to: gotoPage)
				}
			}
		}
	}
	
	func openImgInNewTab(contentId: UUID = UUID(), tabTitle: String? = nil, content: NSImage, source: String? = nil){
		let imgView = ni.getNewImgView(owner: self, parentView: self.view, img: content)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .img, source: source, isSelected: true)
		if let title = tabTitle{
			tabHeadModel.title = title
		}
		tabHeadModel.position = 0
		tabHeadModel.viewItem = imgView
		self.tabs.append(tabHeadModel)
		
		_ = myView.createNewTab(tabView: imgView)
		myView.fixedFrameRatio = content.size.width / content.size.height

		//FIXME: dirty hack to ensure first responder status after space load
		//(needed so the delete key works consistently)
		DispatchQueue.main.async {
			imgView.setActive()
		}
	}
	
	func openNoteInNewTab(contentId: UUID = UUID(), tabTitle: String? = nil, content: String? = nil){
		let noteItem = ni.getNewNoteItem(owner: self, parentView: self.view, frame: self.view.frame, text: content)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .note, isSelected: true)
		tabHeadModel.position = 0
		tabHeadModel.viewItem = noteItem
		self.tabs.append(tabHeadModel)
		
		_ = myView.createNewTab(tabView: noteItem.scrollView)
		framelessView?.setContentItem(item: noteItem)
		noteItem.startEditing()
		myView.window?.makeFirstResponder(noteItem)
	}
	
	func openWebsiteInNewTab(
		urlStr: String,
		contentId: UUID,
		tabName: String,
		webContentState: TabViewModelState? = nil,
		openNextTo: Int = -1,
		as type: TabContentType = .web
	) -> Int{
		let niWebView = getNewWebView(owner: self, frame: view.frame, dirtyUrl: urlStr, contentId: contentId)
		let viewPosition = myView.createNewTab(tabView: niWebView, openNextTo: openNextTo)
		
		if(0 <= openNextTo){
			updateWVTabHeadPos(from: viewPosition, moveLeft: false)
		}
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: type)
		tabHeadModel.position = viewPosition
		tabHeadModel.viewItem = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		tabHeadModel.content = urlStr
		tabHeadModel.state = .loading
		
		if(0 <= openNextTo){
			self.tabs.insert(tabHeadModel, at: viewPosition)
		}else{
			self.tabs.append(tabHeadModel)
		}
		
		return tabHeadModel.position
    }
	
	func openWebsiteInNewTab(
		_ urlStr: String,
		shallSelectTab: Bool = true,
		openNextToSelectedTab: Bool = false,
		as type: TabContentType = .web
	){
        let id = UUID()
		let pos: Int
		if(openNextToSelectedTab){
			let openNXtToPos = self.nxtTabPosOpenNxtTo ?? selectedTabModel
			pos = openWebsiteInNewTab(urlStr: urlStr, contentId: id, tabName: "", openNextTo: openNXtToPos)
			self.nxtTabPosOpenNxtTo = pos
		}else{
			pos = openWebsiteInNewTab(urlStr: urlStr, contentId: id, tabName: "", as: type)
			self.nxtTabPosOpenNxtTo = nil
		}
		
		if(shallSelectTab){
			selectTab(at: pos)
		}else{
			viewWithTabs?.cfTabHeadCollection?.reloadData()
			viewWithTabs?.cfTabHeadCollection?.scrollToItems(at: Set(arrayLiteral: IndexPath(item: pos, section: 0)), scrollPosition: .nearestVerticalEdge)
		}
    }
	
	func loadWebsite(_ url: URL, forTab at: Int){
		let urlReq = URLRequest(url: url)
		
		tabs[at].state = .loading
		tabs[at].webView?.load(urlReq)
	}
	
	func openSourceWebsite(){
		if(selectedTabModel == -1){selectedTabModel = 0}
		if(tabs.count < selectedTabModel){return}
		if(tabs[selectedTabModel].type != .img){return}
		guard let sourceURL = tabs[selectedTabModel].source else{return}
		if(!sourceURL.starts(with: "http")){return}
		
		guard let docController = myView.niParentDoc?.nextResponder as? NiSpaceDocumentController else {return}
		let newCF = docController.openEmptyCF(openInitalTab: false)
		newCF.openWebsiteInNewTab(sourceURL, shallSelectTab: true)
	}
	
	/*
	 * MARK: selecting, closing, editing tabs
	 */
	func closeTab(at position: Int){
		if(position != selectedTabModel){
			//TODO: Before exposing close UI element on non-selected tabs.
			//Implement proper methodology to end editing a URL, before closing a tab
			//otherwise we'll run into an index out of bounds issue
			viewWithTabs?.deleteSelectedTab(at: position)
			var deletedTabModel = self.tabs.remove(at: position)
			viewWithTabs?.cfTabHeadCollection?.reloadData()
			deletedTabModel.viewItem = nil
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
	
	/** does what the name suggests
	 
	 Close tabs and select the nxt tab to the right first and then left when none to the right are left
	 */
	func closeSelectedTab(){
		if(0 < tabs.count && tabs[0].type == .web && viewState == .simpleFrame){
			confirmClose()
			return
		}
		if(!viewHasTabs()){
			return
		}
		
		updateWVTabHeadPos(from: selectedTabModel+1)
		var deletedTabModel: TabViewModel?
		
		if(selectedTabModel == 0 && self.tabs.count == 1){
			deletedTabModel = self.tabs.remove(at: selectedTabModel)
			
			confirmClose()
		}else if(selectedTabModel < (self.tabs.count - 1)){
			let toDeletePos = selectedTabModel
			
			viewWithTabs?.deleteSelectedTab(at: toDeletePos)
			deletedTabModel = self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
			
			viewWithTabs?.cfTabHeadCollection?.reloadData()
		}else if(0 < selectedTabModel){
			let toDeletePos = selectedTabModel
			selectedTabModel -= 1
			
			viewWithTabs?.deleteSelectedTab(at: toDeletePos)
			deletedTabModel = self.tabs.remove(at: toDeletePos)
			
			selectTab(at: selectedTabModel)
			
			viewWithTabs?.cfTabHeadCollection?.reloadData()
		}
		
		if(deletedTabModel != nil){
			DocumentDal.deleteDocument(documentId: deletedTabModel!.contentId, docType: deletedTabModel!.type)
		}

		deletedTabModel?.viewItem = nil
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
	
	/**
	 reloadTabHeads - set this to `false` if you are forcing a reload later in the main-loop. This is used when creating a new tab that immediately goes into editing mode.
	 */
	func selectTab(at: Int, mouseDownEvent: NSEvent? = nil, reloadTabHeads: Bool = true){
		guard (0 <= at && at < tabs.count) else {return}
		//No tab switching while CF is not active
		if(!viewHasTabs() || !self.myView.frameIsActive){
			if(mouseDownEvent != nil){
				nextResponder?.mouseDown(with: mouseDownEvent!)
			}
			return
		}
		
		self.nxtTabPosOpenNxtTo = nil
		
		if(aTabIsInEditingMode && at != selectedTabModel){
			endEditingTabUrl(at: selectedTabModel)
		}
		
		if(aTabIsInEditingMode && at == selectedTabModel){
			return
		}
		
		tryCloseFullScreenPlayback()
		
		forceSelectTab(at: at)
		
		if(reloadTabHeads){
			viewWithTabs?.cfTabHeadCollection?.reloadData()
			viewWithTabs?.cfTabHeadCollection?.scrollToItems(at: Set(arrayLiteral: IndexPath(item: at, section: 0)), scrollPosition: .nearestVerticalEdge)
		}
	}
	
	func viewHasTabs() -> Bool{
		if(viewState == .expanded || viewState == .fullscreen){
			return true
		}
		return false
	}
	
	func pinTabToTopbar(at: Int){
		guard (0 <= at && at < tabs.count) else {return}
		guard let url: URL = tabs[at].webView?.url else{return}
		guard let spaceController: NiSpaceViewController = (NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController() else {return}
		
		spaceController.addPinnedWebApp(name: tabs[at].title, url: url)
	}
	
	//Stopping fullscreen playback, as it otherwise would create empty balck desktop, after switching tabs
	private func tryCloseFullScreenPlayback() {
		if(selectedTabModel < 0 || (tabs.count-1) <= selectedTabModel){
			return
		}
		if let activeWebView = tabs[selectedTabModel].webView{
			Task{
				activeWebView.closeAllMediaPresentations()
			}
		}
	}
	
	/// skipps all checks ensuring UI consistency. Does not reload the TabHead Collection View
	///
	/// Only call this directly, when reloading a space!
	func forceSelectTab(at: Int){
		if(0 <= selectedTabModel){
			tabs[selectedTabModel].isSelected = false
		}
		
		self.viewWithTabs?.niContentTabView.selectTabViewItem(at: at)
		self.viewWithTabs?.updateFwdBackTint()
		
		self.selectedTabModel = at
		tabs[selectedTabModel].isSelected = true
	}
	
	func toggleEditSelectedTab(){
		if(self.viewState == .minimised){
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
			return
		}
		self.aTabIsInEditingMode = true
		tabs[at].inEditingMode = true
		
		viewWithTabs?.cfTabHeadCollection?.reloadData()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
			self.viewWithTabs?.cfTabHeadCollection?.scrollToItems(at: Set(arrayLiteral: IndexPath(item: at, section: 0)), scrollPosition: .right)
		}
		
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
				viewWithTabs?.cfTabHeadCollection?.reloadData()
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
		if(!viewHasTabs()){
			if(0 < tabs.count){
				tabs[0].state = .loaded
			}
			return
		}
		guard let wv = webView as? NiWebView else{return}
		wv.viewLoadedWebsite()
		
		//check if tab was closed by the time this callback happens
		if(tabs.count <= wv.tabHeadPosition || tabs[wv.tabHeadPosition].webView != wv){
			return
		}
		
		wv.retries = 0
		
		self.tabs[wv.tabHeadPosition].title = wv.getTitle() ?? tabs[wv.tabHeadPosition].title
		self.tabs[wv.tabHeadPosition].icon = nil
		
		//an empty tab still loads a local html
		if(self.tabs[wv.tabHeadPosition].state != .empty && self.tabs[wv.tabHeadPosition].state != .error ){
			self.tabs[wv.tabHeadPosition].state = .loaded
			if(wv.url != nil){
				self.tabs[wv.tabHeadPosition].content = wv.url!.absoluteString
			}
			guard !tabs[wv.tabHeadPosition].inEditingMode else {return}
			if let nrOfItems: Int = viewWithTabs?.cfTabHeadCollection?.numberOfItems(inSection: 0){
				if(wv.tabHeadPosition < nrOfItems){
					viewWithTabs?.cfTabHeadCollection?.reloadItems(
						at: Set(arrayLiteral: IndexPath(item: wv.tabHeadPosition, section: 0))
					)
				}
			}
		}
	}
	
	func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error){
		handleFailedLoad(webView)
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error){
		handleFailedLoad(webView)
	}

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		
		if(navigationAction.shouldPerformDownload){
			decisionHandler(.download)
			return
		}
		if let contentType = navigationAction.request.value(forHTTPHeaderField: "Content-Type"){
			if(contentType == "application/pdf"){
				decisionHandler(.download)
				return
			}
		}
		//open in new tab, comand clicked on link
		if(navigationAction.modifierFlags == .command && viewHasTabs()){
			let urlStr = navigationAction.request.url?.absoluteString
			if(urlStr != nil && !urlStr!.isEmpty){
				self.openWebsiteInNewTab(urlStr!, shallSelectTab: false, openNextToSelectedTab: true)
				decisionHandler(.cancel)
				return
			}
		}
		decisionHandler(.allow)
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
		if navigationAction.shouldPerformDownload {
			decisionHandler(.download, preferences)
			return
		}
		
		if let contentType = navigationAction.request.value(forHTTPHeaderField: "Content-Type"){
			if(contentType == "application/pdf"){
				decisionHandler(.download, preferences)
				return
			}
		}
		//open in new tab, comand clicked on link
		if(navigationAction.modifierFlags == .command && viewHasTabs()){
			let urlStr = navigationAction.request.url?.absoluteString
			if(urlStr != nil && !urlStr!.isEmpty){
				self.openWebsiteInNewTab(urlStr!, shallSelectTab: false, openNextToSelectedTab: true)
				decisionHandler(.cancel, preferences)
				return
			}
		}
		decisionHandler(.allow, preferences)
	}
	
	func webView(_ webView: WKWebView, 
				 decidePolicyFor navigationResponse: WKNavigationResponse,
				 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
	) {
		if (navigationResponse.response.mimeType == "application/pdf"){
			decisionHandler(.download)
			if let niWV = webView as? NiWebView{
				if(!niWV.websiteLoaded && viewHasTabs()){
					NiDownloadHandler.instance.setCloseTabCallback(for: niWV)
				}
			}
			return
		}
		if navigationResponse.canShowMIMEType {
			decisionHandler(.allow) // In case of force download file; decisionHandler(.download)
			return
		}
		decisionHandler(.download)
	}
	
	//open in new tab, example clicked file in gDrive
	func webView(_ webView: WKWebView, 
				 createWebViewWith configuration: WKWebViewConfiguration,
				 for navigationAction: WKNavigationAction,
				 windowFeatures: WKWindowFeatures
	) -> WKWebView?{
		
		guard viewHasTabs() else {return nil}
		
		if(navigationAction.targetFrame == nil){
			let urlStr = navigationAction.request.url?.absoluteString
			if(urlStr != nil && !urlStr!.isEmpty){
				self.openWebsiteInNewTab(urlStr!, openNextToSelectedTab: true)
			}
		}
		return nil
	}

	func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload){
		download.delegate = NiDownloadHandler.instance
	}
	
	func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload){
		download.delegate = NiDownloadHandler.instance
	}
	
	func webViewDidClose(_ webView: WKWebView){
		guard viewHasTabs() else {return}
		if let niWebView = webView as? NiWebView{
			closeTab(at: niWebView.tabHeadPosition)
		}
	}
	
	func niWebViewTitleChanged(_ webView: NiWebView){
		guard viewIsDrawn else {return}
		
		if(viewState == .simpleFrame){
			simpleFrame?.cfGroupButton.setView(title: webView.getTitle())
			return
		}
		guard viewHasTabs() else {return}
		
		if(0 <= webView.tabHeadPosition && webView.tabHeadPosition < tabs.count){
			guard !tabs[webView.tabHeadPosition].inEditingMode else {return}
			self.tabs[webView.tabHeadPosition].title = webView.getTitle() ?? tabs[webView.tabHeadPosition].title
			if let nrOfItems: Int = viewWithTabs?.cfTabHeadCollection?.numberOfItems(inSection: 0){
				if(webView.tabHeadPosition < nrOfItems){
					guard let tabHead = viewWithTabs?.cfTabHeadCollection?.item(at: webView.tabHeadPosition) as? ContentFrameTabHead else {return}
					tabHead.updateTitle(newTitle: self.tabs[webView.tabHeadPosition].title)
				}
			}
		}
	}
	
	func niWebViewCanGoBack(_ newValue: Bool, _ webView: NiWebView){
		guard let fwdBackView: CFFwdBackButtonProtocol = view as? CFFwdBackButtonProtocol else {return}
		fwdBackView.setBackButtonTint(newValue, trigger: webView)
	}
	
	func niWebViewCanGoFwd(_ newValue: Bool, _ webView: NiWebView){
		guard let fwdBackView: CFFwdBackButtonProtocol = view as? CFFwdBackButtonProtocol else {return}
		fwdBackView.setForwardButtonTint(newValue, trigger: webView)
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
		
		guard viewHasTabs() else {return}
		
		self.tabs[wv.tabHeadPosition].state = .error
	}
	
	/*
	 * MARK: - Tab Heads collection control functions
	 */
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int{
		if(viewState == .expanded){
			expandedCFView?.recalcDragArea(nrOfTabs: self.tabs.count)
		}
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
		
		let maxWidth = (expandedCFView?.cfHeadView.frame.width ?? 780) / 2
		let nrOfCharacters = viewModel.webView?.url?.absoluteString.count ?? 30
		var tabHeadWidth = CGFloat(nrOfCharacters) * 8.0 + 30
		
		if(maxWidth < tabHeadWidth){
			tabHeadWidth = maxWidth
		}
		
		if(tabHeadWidth < ContentFrameView.DEFAULT_TAB_SIZE.width){
			tabHeadWidth = ContentFrameView.DEFAULT_TAB_SIZE.width
		}
		if(ContentFrameView.MAX_TAB_WIDTH < tabHeadWidth){
			tabHeadWidth = ContentFrameView.MAX_TAB_WIDTH
		}
		
		//fixes ni-172 - if we call the recalcuation live here, before the first item is drawn the following `collectionView.makeItem` calls with have views sized 0,0
		DispatchQueue.main.async {
			self.expandedCFView?.recalcDragArea(specialTabWidth: tabHeadWidth)
		}
		
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
		var lastType: TabContentType?
		for tab in tabs {
			if(tab.type == .img){
				ImgDal.deleteImg(id: tab.contentId)
			}else if(tab.type == .pdf){
				PdfDal.deletePdf(id: tab.contentId)
			}else{
				DocumentDal.deleteDocument(documentId: tab.contentId, docType: tab.type)
			}
			lastType = tab.type
		}
		if let gId = self.groupId{
			GroupTable.deleteRecord(gId)
		}
		PostHogSDK.shared.capture(
			"window_closed",
			properties: ["type": lastType?.rawValue ?? "empty"]
		)
	}
	
	func persistContent(spaceId: UUID){
		if(closeTriggered){
			return
		}
		// we are only doing this for webGroups rn, as otherwise it would mess up our result sets
		if(0 < tabs.count && tabs[0].type == .web){
			DocumentDal.persistGroup(id: groupId, name: groupName)
		}
		for tab in tabs {
//			tab.webView?.evaluateJavaScript("document.documentElement.outerHTML.toString()") { html, e in
//				print(html)
//			}
			DocumentDal.persistDocument(spaceId: spaceId, document: tab, groupId: self.groupId)
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
			var scrollPosition: Int? = nil
			
			if(tab.type == .pdf){
				scrollPosition = (tab.pdfView?.currentPage?.pageRef?.pageNumber ?? 1) - 1
				if(scrollPosition! < 0){
					scrollPosition = 0
				}
			}
			if(tab.type == .web
			   || (tab.type == .note && tab.noteView?.getText() != nil)
			   || tab.type == .img
			   || tab.type == .pdf
			){
				children.append(
					NiCFTabModel(
						id: tab.contentId,
						contentType: tab.type,
						contentState: tab.state.rawValue,
						active: tab.isSelected,
						position: i,
						scrollPosition: scrollPosition
					)
				)
			}
		}
		
		if(children.isEmpty){
			return (model: nil,  nrOfTabs: 0, state: nil)
		}
		
		updateGroupName()
		setIdIfNeeded()
		
		let posInStack = Int(view.layer!.zPosition)
		let model = NiDocumentObjectModel(
			type: NiDocumentObjectTypes.contentFrame,
			data: NiContentFrameModel(
				state: self.viewState,
				previousDisplayState: self.prevDisplayState,
				height: NiCoordinate(px: view.frame.height),
				width: NiCoordinate(px: view.frame.width),
				position: NiViewPosition(
					posInViewStack: posInStack,
					x: NiCoordinate(px: view.frame.origin.x),
					y: NiCoordinate(px: view.frame.origin.y)
				),
				children: children,
				name: self.groupName,
				id: self.groupId
			)
		)

		return (model: model, nrOfTabs: children.count, state: self.viewState)
	}
	
	private func updateGroupName() {
		if (viewState == .expanded){
			self.groupName = expandedCFView?.cfGroupButton.getName()
		}else if (viewState == .minimised){
			if let minimizedView = self.view as? CFMinimizedView{
				self.groupName = minimizedView.cfGroupButton.getName()
			}
		}else if (viewState == .simpleFrame){
			if let simpleView = self.view as? CFSimpleFrameView{
				self.groupName = simpleView.cfGroupButton.getName()
			}
		}
	}
	
	private func setIdIfNeeded(){
		guard self.groupId == nil else {return}
		if(groupName == nil || groupName?.isEmpty == true){
			return
		}
		self.groupId = UUID()
	}
	
	func pauseMediaPlayback(){
		for t in tabs{
			t.viewItem?.spaceClosed()
		}
	}
	
	func deinitSelf(){
		myView.removeFromSuperviewWithoutNeedingDisplay()
		for t in tabs{
			t.viewItem?.spaceRemovedFromMemory()
		}
		tabs = []
		myView.deinitSelf()
		expandedCFView?.deinitSelf()
		
		expandedCFView?.removeFromSuperview()
		view.removeFromSuperview()
		expandedCFView = nil
		groupName = nil
	}
	
}
