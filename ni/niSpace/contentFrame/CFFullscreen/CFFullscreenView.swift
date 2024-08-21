//
//  CFFullscreenView.swift
//  ni
//
//  Created by Patrick Lukas on 12/8/24.
//

import Cocoa

class CFFullscreenView: CFBaseView, CFTabHeadProtocol{

	@IBOutlet var niContentTabView: NSTabView!
	
	@IBOutlet var minimizedIcon: NiActionImage!
	@IBOutlet var pinnedAppIcon: NiActionImage!
	@IBOutlet var searchIcon: NiActionImage!
	@IBOutlet var time: NSTextField!
	@IBOutlet var cfTabHeadCollection: NSCollectionView?
	@IBOutlet var addTabButton: NiActionImage!
	@IBOutlet var contentForwardButton: NiActionImage!
	@IBOutlet var contentBackButton: NiActionImage!
	@IBOutlet var spaceName: NiTextField!
	@IBOutlet var groupName: NiTextField!
	
	
	func initAfterViewLoad(spaceName: String, groupName: String?){
		niContentTabView.wantsLayer = true
		
		addTabButton.setMouseDownFunction(addTabClicked)
		addTabButton.isActiveFunction = {return true}
		
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
		
		//TODO: set guard to call only on webViews
		setWebViewObservers(tabView: tabView)
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
	
	func searchIconClicked(with event: NSEvent){
		(NSApplication.shared.delegate as? AppDelegate)?.showPalette()
	}
	
	func openPinnedMenu(with event: NSEvent){
		(NSApplication.shared.delegate as? AppDelegate)?
			.getNiSpaceViewController()?
			.openPinnedMenu(with: event)
	}
	
	func deleteSelectedTab(at position: Int){
		niContentTabView.removeTabViewItem(niContentTabView.tabViewItem(at: position))
	}
	
	override func mouseDown(with event: NSEvent) {
		return
	}
	
	// MARK: - fwd/back button
	private func setWebViewObservers(tabView: NSView){
		tabView.addObserver(self, forKeyPath: "canGoBack", options: [.initial, .new], context: nil)
		tabView.addObserver(self, forKeyPath: "canGoForward", options: [.initial, .new], context: nil)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let niWebView = niContentTabView.selectedTabViewItem?.view as? NiWebView else {return}
		if keyPath == "canGoBack" {
			self.setBackButtonTint(niWebView.canGoBack)
		}else if keyPath == "canGoForward"{
			self.setForwardButtonTint(niWebView.canGoForward)
		}
	}
	
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
	private func setForwardButtonTint(_ canGoFwd: Bool = false){
		if(canGoFwd){
			self.contentForwardButton.contentTintColor = NSColor(.sand11)
		}else{
			self.contentForwardButton.contentTintColor = NSColor(.sand8)
		}
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
}
