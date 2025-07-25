
//
//  ContentFrameController.swift
//  ni
//
//  Created by Patrick Lukas on 12/3/23.
//

import Foundation
import Cocoa
import Carbon.HIToolbox
import PDFKit
import QuartzCore
import FaviconFinder
import PostHog

//TODO: clean up tech debt and move the delegates out of here
class ContentFrameController: CFProtocol, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {


	/**Call this function when resetting the view. **Do not use it the in init flow, to set the inital view value.***/
	private func resetView(newView: CFBaseView){
		if(viewState != .fullscreen){
			let minimizedOrigin = if(viewState.isMinimized()){
				NiOrigin(view.frame.origin)
			}else{
				prevDisplayState?.minimisedOrigin
			}
			let defaultWindowOrigin = if(viewState.isDefaultViewState()){
				NiOrigin(view.frame.origin)
			}else{
				prevDisplayState?.defaultWindowOrigin
			}
			self.prevDisplayState = NiPreviousDisplayState(
				state: self.viewState,
				expandCollapseDirection: .leftToRight,
				minimisedOrigin: minimizedOrigin,
				defaultWindowOrigin: defaultWindowOrigin
			)
		}
		
		self.view = newView
		self.viewState = myView.frameType
	}
	
	var framelessView: CFFramelessView? {return self.view as? CFFramelessView}
	var simpleFrame: CFSimpleFrameView? {return self.view as? CFSimpleFrameView}
	var viewWithTabs: CFTabHeadProtocol? {return self.view as? CFTabHeadProtocol}
	
	private(set) var expandedCFView: ContentFrameView? = nil
	private var selectedTabModel: Int = 0
	//we need this var to have the behaviour that tabs that get open with cmd+click open in sequence next to each other
	//and not just right next to the current tab
	private var nxtTabPosOpenNxtTo: Int? = nil
	private(set) var aTabIsInEditingMode: Bool = false

	private(set) var viewIsDrawn = false
	
	private var prevDisplayState: NiPreviousDisplayState?
	
	/*
	 * MARK: init & view loading here
	 */
	init(viewState: NiContentFrameState, 
		 groupName: String?,
		 groupId: UUID?,
		 tabsModel: [TabViewModel]? = nil,
		 previousDisplayState: NiPreviousDisplayState? = nil
	){
		
		self.prevDisplayState = previousDisplayState
		
		super.init(nibName: nil, bundle: nil)
		self.groupId = groupId
		self.groupName = groupName
		
		self.viewState = viewState
		if(tabsModel != nil){
			self.tabs = tabsModel!
		}
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
		expandedCFView!.cfHeadView.layer?.backgroundColor = NSColor(.sand5).cgColor
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
		simpleFrameView.layer?.backgroundColor = NSColor.sand5.cgColor
		return simpleFrameView
	}
	
	/** only use this in views with one tab.
	 
	 The tabGroup title reflects the document name. These need to be kept in sync in case the single tab is moved into a group.
	 */
	func simpleViewTitleChangedCallback(_ newTitle: String?){
		if let newTitle = newTitle{
			guard !newTitle.isEmpty && newTitle != "/" else {return}
			tabs[0].title = newTitle
		}
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
			limit: CFCollapsedMinimizedView.tabListLimit,
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
		if(viewState == .minimised || viewState == .collapsedMinimised){
			self.view.layer?.borderColor = NSColor(.sand4).cgColor
			self.view.layer?.backgroundColor = NSColor(.sand4).cgColor
		}else{
			self.view.layer?.borderColor = NSColor(.sand5).cgColor
			self.view.layer?.backgroundColor = NSColor(.sand5).cgColor
		}
	}
	
	override func tryPrintContent(_ sender: Any?){
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
	 * MARK: passToView Functions
	 */
	
	override func reloadSelectedTab(){
		if(viewState != .minimised){
			if(selectedTabModel < 0 && 0 < tabs.count){
				tabs[0].webView?.reload()
			}else if(0 < tabs.count){
				tabs[selectedTabModel].webView?.reload()
			}
		}
	}
	
	/*
	 * MARK: transitions between views
	 */
	override func minimizeSelf(){
		switch (viewState, prevDisplayState?.state) {
			case (.expanded, .collapsedMinimised):
				minimizeToCollapsed(to: prevDisplayState?.minimisedOrigin?.toNSPoint())
				break
			case (.expanded, _):
				minimizeSelfToDefault(to: prevDisplayState?.minimisedOrigin?.toNSPoint())
				break
			case (.fullscreen, _):
				fullscreenToExpanded()
				break
			case (.simpleFrame, _):
				minimizeSelfToSimple(to: prevDisplayState?.minimisedOrigin?.toNSPoint())
				break
			default:
				assertionFailure("Unhandled combination of current and previous view state")
				break
		}
	}
	
	func minimizeClicked(_ event: NSEvent) {
		minimizeSelf()
	}
	
	private func minimizeSelfToDefault(to origin: NSPoint? = nil){
		updateTabViewModel()
		let minimizedView = loadMinimizedView()
		minimizedView.setFrameOwner(myView.niParentDoc)
		positionMinimizedView(for: minimizedView, predefinedPos: origin)
		
		//replace
		self.view.superview?.replaceSubview(self.view, with: minimizedView)
		resetView(newView: minimizedView)

		self.myView.niParentDoc?.setTopNiFrame(self)
		sharedLoadViewSetters()
	}
	
	private func minimizeSelfToSimple(to origin: NSPoint? = nil){
		guard safeGetTab(at: 0)?.type == .pdf else {return}
		let simpleMinimizedView = loadSimpleMinimzedView()
		simpleMinimizedView.setFrameOwner(myView.niParentDoc)
		
		positionMinimizedView(for: simpleMinimizedView, predefinedPos: origin)
		//replace
		if let zPos = self.view.layer?.zPosition{
			simpleMinimizedView.layer?.zPosition = zPos
		}
		let oldView = self.myView
		self.view.superview?.replaceSubview(self.view,
											with: simpleMinimizedView)
		resetView(newView: simpleMinimizedView)
		
		self.myView.niParentDoc?.setTopNiFrame(self)
		oldView.deinitSelf()
	}
	
	private func positionMinimizedView(for minimizedView: CFBaseView, predefinedPos: CGPoint? = nil){
		if(self.view.layer != nil){
			minimizedView.layer?.zPosition = self.view.layer!.zPosition
		}
		
		if let predefinedPos{
			minimizedView.frame.origin = predefinedPos
			moveWithinBounds(minimizedView)
			return
		}
		minimizedView.frame.origin.y = self.view.frame.origin.y
		minimizedView.frame.origin.x = self.view.frame.origin.x + self.view.frame.width - minimizedView.frame.width
		
		if let niDocWidth: CGFloat = self.myView.niParentDoc?.frame.width{
			if(niDocWidth < (minimizedView.frame.origin.x + minimizedView.frame.width)){
				minimizedView.frame.origin.x = niDocWidth - minimizedView.frame.width - CFBaseView.CFConstants.defaultMargin
			}
		}
	}
	
	private func moveWithinBounds(_ cfView: CFBaseView){
		guard let superViewMaxX: CGFloat = view.superview?.frame.maxX else {return}
		guard (superViewMaxX < cfView.frame.maxX) else {return}
		cfView.frame.origin.x = superViewMaxX - cfView.frame.width
	}
	
	override func maximizeSelf(){
		switch viewState {
			case .minimised, .collapsedMinimised:
				minimizedToExpanded()
			case .simpleMinimised:
				simpleMinimizedToSimpleFrame()
			default:
				assertionFailure("Unhandled view state to self-maximize")
		}
	}
	
	override func toggleFullscreen(){
		if(viewState == .fullscreen){
			fullscreenToPreviousState()
		}else if([.minimised, .collapsedMinimised].contains(viewState)){
			minimizedToFullscreen()
		}else if(viewState == .expanded){
			expandedToFullscreen()
		}
	}
	
	func makeFullscreenClicked(_ event: NSEvent){
		if(viewState == .expanded){
			expandedToFullscreen()
		}
	}

	override func minimizedToFullscreen() {
		assert([.minimised, .collapsedMinimised].contains(viewState))

		let oldState = viewState
		let oldPosition = NiOrigin(view.frame.origin)
		// Workaround: Directly expanding to fullscreen will not display the controller on the topmost Z level: other expanded views will be displayed on top. Expanding minimized views first takes care of that.
		self.minimizedToExpanded()
		self.expandedToFullscreen()

		// Set previous display state to the minimised state (would be `.expanded` with the workaround above all the time otherwise)
		self.prevDisplayState = NiPreviousDisplayState(
			state: oldState,
			expandCollapseDirection: .leftToRight,
			minimisedOrigin: oldPosition
		)
	}

	override func expandedToFullscreen(){
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
		resetView(newView: fullscreenView)
		
		(NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController()?.hideHeader()
		
		self.myView.niParentDoc?.setTopNiFrame(self)
	}
	
	func simpleFrameToFullscreen(){
		guard let webviewToPass = simpleFrame?.myContent as? NiWebView else {return}
		let fullscreenView = loadFullscreenView()
		fullscreenView.setFrameOwner(myView.niParentDoc)
		_ = fullscreenView.createNewTab(tabView: webviewToPass)
		
		if let zPos = self.view.layer?.zPosition{
			fullscreenView.layer?.zPosition = zPos
		}
		fullscreenView.fillView(with: nil)
		
		self.view.superview?.replaceSubview(self.view, with: fullscreenView)
		self.myView.deinitSelf(keepContentView: true)
		resetView(newView: fullscreenView)
		
		(NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController()?.hideHeader()
		
		self.myView.niParentDoc?.setTopNiFrame(self)
	}
	
	func simpleFrameToExpanded(){
		groupName = nil

		if(expandedCFView == nil){
			_ = recreateExpandedCFView()
			expandedCFView?.setFrameOwner(self.myView.niParentDoc)
		}
		expandedCFView?.frame = myView.frame
		if(self.view.layer != nil){
			expandedCFView?.layer?.zPosition = self.view.layer!.zPosition
		}
				
		//replace
		self.view.superview?.replaceSubview(self.view, with: expandedCFView!)
		self.myView.deinitSelf()
		resetView(newView: expandedCFView!)
		
		forceSelectTab(at: 0)
		
		self.expandedCFView!.niParentDoc?.setTopNiFrame(self)
		
		sharedLoadViewSetters()
	}

	func fullscreenToPreviousState() {
		assert(self.viewState == .fullscreen)
		let previousState = prevDisplayState

		
		if(prevDisplayState?.state == .expanded){
			fullscreenToExpanded()
		}else{
			// Minimizing is only supported from expanded state, so transition to expanded first.
			fullscreenToExpanded()
		}

		switch previousState?.state {
			case .collapsedMinimised:
				minimizeToCollapsed(to: previousState?.minimisedOrigin?.toNSPoint())
			case .minimised:
				minimizeSelfToDefault(to: previousState?.minimisedOrigin?.toNSPoint())
			case .simpleMinimised,
				 .frameless:
				assertionFailure("\(String(describing: previousState?.state)) view should never have been in fullscreen mode")
			default:
				// .expanded Already handled by default `fullscreenToExpanded`
				// .fullscreen Keep expanded view if we don't know any non-fullscreen state
				// .simpleFrame returns to expanded after being in fullscreen, as the user may have added tabs
				break
		}
	}

	func fullscreenToExpanded(to predefinedOrigin: NSPoint? = nil){
		var reloadTabHeads = false
		if(expandedCFView == nil){
			loadExpandedView()
			expandedCFView?.setFrameOwner(self.myView.niParentDoc)
			expandedCFView?.cfGroupButton.setView(title: groupName)
			
		}else{
			reloadTabHeads = true
		}
		
		if let predefinedOrigin{
			expandedCFView?.frame.origin = predefinedOrigin
		}else{
			if(expandedCFView!.frame.origin.y < 50.0){
				expandedCFView?.frame.origin.y = 50.0
			}
			if(expandedCFView!.frame.origin.x < 50.0){
				expandedCFView?.frame.origin.x = 50.0
			}
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

		resetView(newView: expandedCFView!)

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
	
	override func minimizedToExpanded(_ shallSelectTabAt: Int = -1){
		
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
			expandedCFView?.frame.size = calcDefaultCFSize()
			expandedCFView?.setFrameOwner(self.myView.niParentDoc)
		}else{
			tabSelectedInModel = selectedTabModel
		}
		positionBiggerView(for: expandedCFView!, predefinedPos: prevDisplayState?.defaultWindowOrigin?.toNSPoint())

		//replace
		self.view.superview?.replaceSubview(self.view, with: expandedCFView!)
		self.myView.deinitSelf()

		resetView(newView: expandedCFView!)
		
		expandedCFView?.cfGroupButton.setView(title: groupName)
		
		if(0 <= shallSelectTabAt){
			forceSelectTab(at: shallSelectTabAt)
			loadSiteIfNotLoadedYet(at: shallSelectTabAt)
		}else{
			forceSelectTab(at: tabSelectedInModel)
			loadSiteIfNotLoadedYet(at: tabSelectedInModel)
		}
		
		
		self.expandedCFView!.niParentDoc?.setTopNiFrame(self)
		
		sharedLoadViewSetters()
	}
	
	private func calcDefaultCFSize() -> CGSize{
		guard let screenSize: CGSize = view.window?.screen?.visibleFrame.size else {return NiSpaceDocumentController.defaultCFSize}
		return Enai.calcDefaultCFSize(for: screenSize)
	}
	
	override func minimizeToCollapsed(to origin: NSPoint? = nil){
		updateTabViewModel()
		if let oldView = self.view as? CFHasGroupButtonProtocol{
			groupName = oldView.cfGroupButton.getName()
		}
		let collapsedView = loadCollapsedMinizedView()
		positionMinimizedView(for: collapsedView, predefinedPos: origin)
		collapsedView.setFrameOwner(myView.niParentDoc)

		//replace
		self.view.superview?.replaceSubview(self.view, with: collapsedView)

		resetView(newView: collapsedView)

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

		resetView(newView: minimizedView)
		
		self.myView.niParentDoc?.setTopNiFrame(self)
		sharedLoadViewSetters()
	}
	
	private func simpleMinimizedToSimpleFrame(){
		let simpleFrameView = loadSimpleFrameView()
		if(tabs[0].viewItem == nil){
			guard tabs[0].type == .pdf else {fatalError("transition from SimpleMinimizedView to SimpleView for \(tabs[0].type) has not been implemented.")}
			guard let pdfDoc = tabs[0].data as? PDFDocument else{return}
			tabs[0].viewItem = getNewPdfView(owner: self, frame: simpleFrameView.frame, document:pdfDoc)
		}
		simpleFrameView.setFrameOwner(myView.niParentDoc)
		simpleFrameView.createNewTab(tabView: tabs[0].viewItem as! NSView)
		positionBiggerView(for: simpleFrameView, predefinedPos: prevDisplayState?.defaultWindowOrigin?.toNSPoint())
		if let zPos = self.view.layer?.zPosition{
			simpleFrameView.layer?.zPosition = zPos
		}
		let oldView = self.myView
		self.view.superview?.replaceSubview(self.view, with: simpleFrameView)

		resetView(newView: simpleFrameView)
		
		self.myView.niParentDoc?.setTopNiFrame(self)
		
		oldView.deinitSelf()
	}
	
	/**
	 used to position expanded and simpleFrame views, after clicking the maximizeButton in their minimized Versions
	 */
	private func positionBiggerView(for biggerView: CFBaseView, predefinedPos: CGPoint? = nil){
		if(self.view.layer != nil){
			biggerView.layer?.zPosition = self.view.layer!.zPosition
		}
		
		if let predefinedPos{
			biggerView.frame.origin = predefinedPos
			moveWithinBounds(biggerView)
			return
		}
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
	}
	
	func recreateExpandedCFView() -> Int {
		loadExpandedView()
		var selectedTabPos: Int = 0
		
		for i in tabs.indices{
			let wview: NiWebView
			if tabs[i].webView == nil{
				//loads only the selected site for improved performance
				if(tabs[i].isSelected){
					wview = getNewWebView(owner: self, frame: expandedCFView!.frame, dirtyUrl: tabs[i].content, contentId: tabs[i].contentId)
					tabs[i].state = .loading
				}else{
					wview = getNewWebView(owner: self, frame: expandedCFView!.frame, dirtyUrl: tabs[i].content, contentId: tabs[i].contentId, loadSite: false)
					tabs[i].state = .notLoaded
				}
				tabs[i].viewItem = wview
			}else{
				wview = tabs[i].webView!
			}
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
		let niWebView = Enai.getNewWebView(owner: self, contentId: contentId, frame: view.frame, fileUrl: nil)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .web)
		tabHeadModel.position = myView.createNewTab(tabView: niWebView)
		tabHeadModel.viewItem = niWebView
		tabHeadModel.state = .loading
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		self.tabs.append(tabHeadModel)
		
		selectTab(at: tabHeadModel.position, reloadTabHeads: reloadTabHeads)
		
		return tabHeadModel.position
	}
	
	override func openAndEditEmptyWebTab(createInfoText: Bool = true){
		if(!viewHasTabs()){
			return
		}
		var lstOfTitles: [String] = []
		for t in tabs{
			lstOfTitles.append(t.title)
		}
		let pos = openEmptyWebTab(reloadTabHeads: false)
		//needs to happen a frame later as otherwise the cursor will not jump into the editing mode
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
			self.editTabUrl(at: pos)
		}
		let spaceName: String = (myView.niParentDoc?.nextResponder as? NiSpaceDocumentController)?.niSpaceName ?? ""
		
		if(createInfoText){
			Task{
				if let welcomeTxt = await Eve.instance.getInfoText(
					for: spaceName, groupName: self.groupName, tabTitles: lstOfTitles
				){
					self.safeGetTab(at: pos)?.webView?.setWelcomeMessage(welcomeTxt)
				}
			}
		}
	}
	
	func openPdfInNewTab(contentId: UUID = UUID(), tabTitle: String? = nil, content: PDFDocument, source: String? = nil, scrollTo pageNr: Int? = nil){
		let pdfView = Enai.getNewPdfView(owner: self, frame: self.view.frame, document: content)
		
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
		let imgView = Enai.getNewImgView(owner: self, parentView: self.view, img: content)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .img, source: source, isSelected: true)
		if let title = tabTitle{
			tabHeadModel.title = title
		}
		tabHeadModel.position = 0
		tabHeadModel.viewItem = imgView
		self.tabs.append(tabHeadModel)
		
		framelessView?.createNewTab(tabView: imgView, of: .img)
		myView.fixedFrameRatio = content.size.width / content.size.height

		//FIXME: dirty hack to ensure first responder status after space load
		//(needed so the delete key works consistently)
		DispatchQueue.main.async {
			imgView.setActive()
		}
	}
	
	func openNoteInNewTab(contentId: UUID = UUID(), tabTitle: String? = nil, content: String? = nil){
		let noteItem = Enai.getNewNoteItem(owner: self, parentView: self.view, frame: self.view.frame, text: content)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .note, isSelected: true)
		tabHeadModel.position = 0
		tabHeadModel.viewItem = noteItem
		self.tabs.append(tabHeadModel)
		
		framelessView?.createNewTab(tabView: noteItem.scrollView, of: .note)
		framelessView?.setContentItem(item: noteItem)
		noteItem.startEditing()
		self.myView.window?.makeFirstResponder(noteItem.scrollView.documentView)
	}
	
	func openStickyInNewTab(contentId: UUID = UUID(), tabTitle: String? = nil, content: String? = nil, color: StickyColor){
		let noteItem = Enai.getNewStickyItem(owner: self, parentView: self.view, color: color, frame: self.view.frame, text: content)
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: .sticky, isSelected: true)
		tabHeadModel.position = 0
		tabHeadModel.viewItem = noteItem
		self.tabs.append(tabHeadModel)
		
		framelessView?.createNewTab(tabView: noteItem.scrollView, of: .sticky)
		framelessView?.setContentItem(item: noteItem)
		noteItem.startEditing()
		self.myView.window?.makeFirstResponder(noteItem.scrollView.documentView)
	}
	
	func openWebsiteInNewTab(
		urlStr: String,
		contentId: UUID,
		tabName: String,
		webContentState: TabViewModelState? = nil,
		openNextTo: Int = -1,
		as type: TabContentType = .web,
		loadWebsite: Bool = true
	) -> Int{
		let niWebView = if(type == .eveChat){
			Enai.getNewWebView(owner: self, contentId: contentId, frame: view.frame, fileUrl: nil)
		}else{
			getNewWebView(owner: self, frame: view.frame, dirtyUrl: urlStr, contentId: contentId, loadSite: loadWebsite)
		}
		let viewPosition = myView.createNewTab(tabView: niWebView, openNextTo: openNextTo)
		
		if(0 <= openNextTo){
			updateWVTabHeadPos(from: viewPosition, moveLeft: false)
		}
		
		var tabHeadModel = TabViewModel(contentId: contentId, type: type, title: tabName)
		tabHeadModel.position = viewPosition
		tabHeadModel.viewItem = niWebView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		tabHeadModel.content = urlStr
		tabHeadModel.state = if(webContentState != nil){
			webContentState!
		}else if(loadWebsite || type == .eveChat){
			.loading
		}else{
			.notLoaded
		}
		
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
		
		tabs[at].type = .web
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
	func safeGetTab(at position: Int) -> TabViewModel?{
		if(position < tabs.count && 0 <= position){
			return tabs[position]
		}
		return nil
	}
	
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
	override func closeSelectedTab(){
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
		
		//TODO: load website of selected website if not loaded
		loadSiteIfNotLoadedYet(at: selectedTabModel)
	}
	
	override func selectNextTab(goFwd: Bool = true){
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
		loadSiteIfNotLoadedYet(at: nxtTab)
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
				activeWebView.niStopMediaPlayingAndLoading()
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
	
	override func toggleEditSelectedTab(){
		if(self.viewState.isMinimized()){
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
	
	func updateViewModelIcon(at: Int, icon: sending NSImage?){
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
		guard indexPath.item < tabs.count else {return ContentFrameView.DEFAULT_TAB_SIZE}
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
		
		return NSSize(width: tabHeadWidth, height: ContentFrameView.TAB_HEAD_HEIGHT)
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
	
	override func purgePersistetContent(){
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
	
	override func persistContent(spaceId: UUID){
		if(closeTriggered){
			return
		}
		// we are only doing this for webGroups rn, as otherwise it would mess up our result sets
		if(0 < tabs.count && tabs[0].type == .web){
			DocumentDal.persistGroup(id: groupId, name: groupName, spaceId: spaceId)
		}
		for tab in tabs {
			DocumentDal.persistDocument(spaceId: spaceId, document: tab, groupId: self.groupId)
		}
	}
	
	override func toNiContentFrameModel() -> (model: NiDocumentObjectModel?, nrOfTabs: Int, state: NiContentFrameState?){
		
		//do nothing, as we are in the deletion process
		if(closeTriggered){
			purgePersistetContent()
			return (model: nil,  nrOfTabs: 0, state: nil)
		}
		
		var children: [NiCFTabModel] = []
		
		for (i, tab) in tabs.enumerated(){
			if(tab.isEveChat()){
				tabs[i].type = .eveChat
			}
			
			if(tab.shouldPersistContent()){
				children.append(
					tabs[i].toNiCFTabModel(at: i)
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
	
	override func updateGroupName(_ n: String?){
		self.groupName = n
	}
	
	private func setIdIfNeeded(){
		guard self.groupId == nil else {return}
		if(groupName == nil || groupName?.isEmpty == true){
			return
		}
		self.groupId = UUID()
	}
	
	override func pauseMediaPlayback(){
		for t in tabs{
			t.viewItem?.spaceClosed()
		}
	}
	
	func provideContext(maxContextSize: Int, startingPos: Int? = nil) -> [String]{
		var remainingContextSize: Int = maxContextSize
		var groupContext: [String] = []

		
		let (remContext, gRes) = provideContext(remainingTokens: remainingContextSize, startingPos: startingPos)
		remainingContextSize = remContext
		groupContext.append(contentsOf: gRes)
		
		guard let allGroupsInSpace = myView.niParentDoc?.orderedContentFrames(closestTo: self) else{
			return groupContext
		}
		
		for group in allGroupsInSpace{
			if(group != self && group.tabs.first?.type == .web){
				if let cfcGroup = group as? ContentFrameController{
					let (rContext, groupRes) = cfcGroup.provideContext(remainingTokens: remainingContextSize)
					remainingContextSize = rContext
					groupContext.append(contentsOf: groupRes)
				}
			}
		}
		return groupContext
	}
	
	private func provideContext(remainingTokens: Int, startingPos: Int? = nil) -> (Int, [String]){
		var remainingContextSize = remainingTokens
		var groupContext: [String] = []
		

		for t in tabs{
			if let extractedContent = ContentTable.fetchExtractedContent(for: t.contentId){
				let nrOfTokens = extractedContent.count / 4
				if(0 < (remainingContextSize - nrOfTokens)){
					groupContext.append(extractedContent)
					remainingContextSize = remainingContextSize - nrOfTokens
				}else{
					return (remainingContextSize, groupContext)
				}
			}
		}
		
		return (remainingContextSize, groupContext)
	}
	
	override func deinitSelf(){
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
