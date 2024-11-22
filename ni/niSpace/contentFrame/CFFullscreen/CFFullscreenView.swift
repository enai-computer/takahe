//
//  CFFullscreenView.swift
//  ni
//
//  Created by Patrick Lukas on 12/8/24.
//

import Cocoa

class CFFullscreenView: CFBaseView, CFTabHeadProtocol, CFFwdBackButtonProtocol{

	@IBOutlet var niContentTabView: NSTabView!
	
	@IBOutlet var cfHeadView: ContentFrameHeadView!
	@IBOutlet var minimizedIcon: NiActionImage!
	@IBOutlet var pinnedAppIcon: NiActionImage!
	@IBOutlet var searchIcon: NiActionImage!
	@IBOutlet var time: NSTextField!
	@IBOutlet var cfTabHeadCollection: NSCollectionView?
	@IBOutlet var addTabButton: NiActionImage!
	@IBOutlet var switchGroupInSpaceButton: NiActionImage!
	@IBOutlet var contentForwardButton: NiActionImage!
	@IBOutlet var contentBackButton: NiActionImage!
	@IBOutlet var spaceName: NiTextField!
	@IBOutlet var groupName: NiTextField!
	
	override var frameType: NiContentFrameState {return .fullscreen}
	
	func initAfterViewLoad(spaceName: String, groupName: String?){
		niContentTabView.wantsLayer = true
		
		addTabButton.setMouseDownFunction(addTabClicked)
		addTabButton.isActiveFunction = {return true}

		switchGroupInSpaceButton.setMouseDownFunction(switchGroupInSpace)
		contentBackButton.setMouseDownFunction(backButtonClicked)
		contentBackButton.isActiveFunction = backButtonIsActive
		
		contentForwardButton.setMouseDownFunction(forwardButtonClicked)
		contentForwardButton.isActiveFunction = fwdButtonIsActive
		
		searchIcon.setMouseDownFunction(searchIconClicked)
		searchIcon.isActiveFunction = {return true}
		
		pinnedAppIcon.setMouseDownFunction(openPinnedMenu)
		pinnedAppIcon.isActiveFunction = {return true}
		
		minimizedIcon.setMouseDownFunction(minimizedButtonClicked)
		minimizedIcon.isActiveFunction = {return true}
		
		if(groupName != nil && !groupName!.isEmpty){
			self.spaceName.stringValue = spaceName + ":"
			self.groupName.stringValue = groupName!
		}else{
			self.spaceName.stringValue = spaceName
			self.groupName.stringValue = ""
		}
		
		time.stringValue = getLocalisedTime()
		setAutoUpdatingTime()
		frameIsActive = true
		
		cfHeadView.wantsLayer = true
		cfHeadView.layer?.backgroundColor = NSColor(.sand5).cgColor
	}
	
	override func repositionView(_ xDiff: Double, _ yDiff: Double) {
		return
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> CFBaseView.OnBorder {
		return .no
	}
	
	override func resizeOwnFrame(_ xDiff: Double, _ yDiff: Double, cursorLeftSide invertX: Bool = false, cursorTop invertY: Bool = false) {
		return
	}
	
	override func fillView(with event: NSEvent?) {
		let visibleView = self.niParentDoc!.visibleRect
		self.frame = visibleView
	}
	
	override func toggleActive() {
		frameIsActive = !frameIsActive
		let webView = niContentTabView.selectedTabViewItem?.view as? CFContentItem	//a new content frame will not have a webView yet
		
		if frameIsActive{
			webView?.setActive()
			self.resetCursorRects()

		}else{
			_ = webView?.setInactive()
			self.discardCursorRects()
		}
	}
	
	override func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int {
		let tabViewPos: Int
		let tabViewItem = NSTabViewItem()
		tabViewItem.view = tabView
		
		//check that open nextTo is set and within bounds (e.g. not the last element)
		if(openNextTo < 0 || (myController!.tabs.count - 1) <= openNextTo){
			tabViewPos = niContentTabView.numberOfTabViewItems
			niContentTabView.addTabViewItem(tabViewItem)
		}else{
			tabViewPos = openNextTo + 1
			niContentTabView.insertTabViewItem(tabViewItem, at: tabViewPos)
		}
		return tabViewPos
	}
	
	func updateSpaceName(_ newVal: String){
		if(!groupName.stringValue.isEmpty){
			self.spaceName.stringValue = newVal + ":"
		}else{
			self.spaceName.stringValue = newVal
		}
	}
	
	func addTabClicked(with event: NSEvent){
		if let cfc = self.nextResponder as? ContentFrameController{
			cfc.openAndEditEmptyWebTab()
		}
	}

	func switchGroupInSpace(with event: NSEvent) {
		assert(niParentDoc != nil)
		guard let groups = niParentDoc?.orderedContentFrames().filter(\.viewState.canBecomeFullscreen) else { return }

		var items: [NiMenuItemViewModel] = groups.map { groupController in
			if self.frameIsActive && groupController === myController {
				NiMenuItemViewModel(
					label: .init(fromContentFrameController: groupController),
					isEnabled: false,
					mouseDownFunction: nil
				)
			} else {
				NiMenuItemViewModel(
					label: .init(fromContentFrameController: groupController),
					isEnabled: true,
					mouseDownFunction: { [myController] _ in
						// Exit fullscreen first, otherwise the space's header will not be hidden correctly as shrinking to expanded would re-display it.
						myController?.fullscreenToPreviousState()
						switch groupController.viewState {
							case .collapsedMinimised, .minimised:
								groupController.minimizedToFullscreen()
							case .expanded:
								groupController.expandedToFullscreen()
							case .fullscreen:
								assert(groupController === myController, "No other group should have been in fullscreen mode")
							case .frameless, .simpleFrame, .simpleMinimised:
								assertionFailure("Unexpected state change from \(groupController.viewState) to full screen")
						}
					}
				)
			}
		}
		items.append(NiMenuItemViewModel(
			title: "open a new group",
			isEnabled: true,
			mouseDownFunction: { [myController] _ in
				myController?.fullscreenToPreviousState()
				guard let appDel = NSApplication.shared.delegate as? AppDelegate else{return}
				
				let newGroup = appDel.getNiSpaceViewController()?.openEmptyCF()
				newGroup?.expandedToFullscreen()
			})
		)
		var menuOrigin = cfHeadView.convert(switchGroupInSpaceButton.frame.origin, to: nil)
		menuOrigin.y += 9
		menuOrigin.x -= 9
		let menuWin = NiMenuWindow(
			origin: menuOrigin,
			dirtyMenuItems: items,
			currentScreen: self.window!.screen!
		)
		menuWin.makeKeyAndOrderFront(nil)
	}

	func searchIconClicked(with event: NSEvent){
		(NSApplication.shared.delegate as? AppDelegate)?.showPalette()
	}
	
	func openPinnedMenu(with event: NSEvent){
		let pointInHeader = CGPoint(x: pinnedAppIcon.frame.midX, y: pinnedAppIcon.frame.minY)
		let pointOnScreen = cfHeadView.convert(pointInHeader, to: nil)
		(NSApplication.shared.delegate as? AppDelegate)?
			.getNiSpaceViewController()?
			.openPinnedMenu(point: pointOnScreen)
	}
	
	func deleteSelectedTab(at position: Int){
		guard 0 <= position && position < niContentTabView.tabViewItems.count else {return}
		niContentTabView.removeTabViewItem(niContentTabView.tabViewItem(at: position))
	}
	
	override func mouseDown(with event: NSEvent) {
		if !frameIsActive{
			niParentDoc?.setTopNiFrame(myController!)
			return
		}
	}
	
	// MARK: - fwd/back button
	func minimizedButtonClicked(with event: NSEvent){
		myController?.fullscreenToExpanded()
	}
	
	func forwardButtonClicked(with event: NSEvent){
		let activeTabView = niContentTabView.selectedTabViewItem?.view as! NiWebView
		activeTabView.goForward()
	}
	
	func backButtonClicked(with event: NSEvent){
		let activeTabView = niContentTabView.selectedTabViewItem?.view as! NiWebView
		activeTabView.goBack()
	}
	
	func updateFwdBackTint(){
		self.setBackButtonTint(backButtonIsActive())
		self.setForwardButtonTint(fwdButtonIsActive())
	}
	
	func fwdButtonIsActive() -> Bool{
		guard let niWebView = niContentTabView.selectedTabViewItem?.view as? NiWebView else {return false}
		return niWebView.canGoForward
	}
	
	func backButtonIsActive() -> Bool{
		guard let niWebView = niContentTabView.selectedTabViewItem?.view as? NiWebView else {return false}
		return niWebView.canGoBack
	}
	
	@MainActor
	private func setBackButtonTint(_ canGoBack: Bool = false){
		if(canGoBack){
			self.contentBackButton.contentTintColor = NSColor(.sand11)
		}else{
			self.contentBackButton.contentTintColor = NSColor(.sand8)
		}
	}
	
	@MainActor
	func setBackButtonTint(_ canGoBack: Bool = false, trigger: NSView){
		guard trigger == niContentTabView.selectedTabViewItem?.view else {return}
		setBackButtonTint(canGoBack)
	}
	
	@MainActor
	private func setForwardButtonTint(_ canGoFwd: Bool = false){
		if(canGoFwd){
			self.contentForwardButton.contentTintColor = NSColor(.sand11)
		}else{
			self.contentForwardButton.contentTintColor = NSColor(.sand8)
		}
	}
	
	@MainActor
	func setForwardButtonTint(_ canGoFwd: Bool = false, trigger: NSView){
		guard trigger == niContentTabView.selectedTabViewItem?.view else {return}
		setForwardButtonTint(canGoFwd)
	}
	
	func setAutoUpdatingTime(){
		Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(setDisplayedTime), userInfo: nil, repeats: true)
	}
	
	func removeAutoUpdatingTime(){
		Timer.cancelPreviousPerformRequests(withTarget: setDisplayedTime())
	}
	
	@objc func setDisplayedTime(){
		let currentTime = getLocalisedTime()
		DispatchQueue.main.async {
			self.time.stringValue = currentTime
		}
	}
	
	override func removeFromSuperview() {
		removeAutoUpdatingTime()
		super.removeFromSuperview()
	}
	
	override func deinitSelf(keepContentView: Bool = false){
		if(keepContentView){
			assertionFailure("option not implemented")
			return
		}
		
		for t in niContentTabView.tabViewItems{
			if let niContentView = t.view as? CFContentItem{
				niContentView.spaceRemovedFromMemory()
			}
			niContentTabView.removeTabViewItem(t)
		}
		niContentTabView.tabViewItems = []
		niContentTabView.removeFromSuperviewWithoutNeedingDisplay()

		cfTabHeadCollection?.dataSource = nil
		cfTabHeadCollection?.delegate = nil
		cfTabHeadCollection?.removeFromSuperviewWithoutNeedingDisplay()

		minimizedIcon.deinitSelf()
		pinnedAppIcon.deinitSelf()
		searchIcon.deinitSelf()
		addTabButton.deinitSelf()
		switchGroupInSpaceButton.deinitSelf()
		contentForwardButton.deinitSelf()
		contentBackButton.deinitSelf()
		
		super.deinitSelf()
	}
}
