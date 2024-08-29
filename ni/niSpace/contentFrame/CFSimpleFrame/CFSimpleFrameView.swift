//
//  CFSimpleFrameView.swift
//  ni
//
//  Created by Patrick Lukas on 4/7/24.
//

import Cocoa
import SwiftSoup

class CFSimpleFrameView: CFBaseView{
	
	@IBOutlet var cfHeadView: ContentFrameHeadView!
	@IBOutlet var cfHeadDragArea: NSView!
	@IBOutlet var cfGroupButton: CFGroupButton!
	@IBOutlet var maximizeButton: NiActionImage!
	@IBOutlet var minimizeButton: NiActionImage!
	@IBOutlet var closeButton: NiActionImage!
	@IBOutlet var placeholderView: NSView!
	@IBOutlet var backButton: NiActionImage!
	@IBOutlet var forwardButton: NiActionImage!
	
	private var myContent: CFContentItem?
	
	private var dropShadow2 = CALayer()
	private var dropShadow3 = CALayer()
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.wantsLayer = true
	}
	
	func initAfterViewLoad(_ groupName: String?, 
						   titleChangedCallback: ((String)->Void)?){
		closeButton.setMouseDownFunction(clickedCloseButton)
		closeButton.isActiveFunction = self.isFrameActive
		closeButton.mouseDownInActiveFunction = activateContentFrame
		
		maximizeButton.setMouseDownFunction(fillOrRetractView)
		maximizeButton.isActiveFunction = self.isFrameActive
		maximizeButton.mouseDownInActiveFunction = activateContentFrame
		
		cfGroupButton.initButton(
			mouseDownFunction: clickedGroupButton,
			mouseDownInActiveFunction: activateContentFrame,
			isActiveFunction: self.isFrameActive,
			titleChangedCallback: titleChangedCallback,
			displayType: .simpleFrame
		)
		cfGroupButton.setView(title: groupName)
		
		minimizeButton.setMouseDownFunction(clickedMinimizeButton)
		minimizeButton.isActiveFunction = self.isFrameActive
		minimizeButton.mouseDownInActiveFunction = activateContentFrame
		
		backButton.isHidden = true
		forwardButton.isHidden = true
	}
	
	@discardableResult
	override func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int {
		tabView.frame = placeholderView.frame
		tabView.autoresizingMask = placeholderView.autoresizingMask
		placeholderView.removeFromSuperview()
		
		tabView.wantsLayer = true
		tabView.layer?.cornerRadius = 10.0
		tabView.layer?.cornerCurve = .continuous
		
		contentView?.addSubview(tabView)
		if let contentItem = tabView as? CFContentItem{
			myContent = contentItem
			if(contentItem is NiWebView){
				minimizeButton.isActiveFunction = {return false}
				minimizeButton.tintInactive()
				cfGroupButton.isActiveFunction = {return false}
				setUpFwdBackButton()
			}
		}
		return -1
	}
	
	override func layout() {
		super.layout()
		
		if(frameIsActive){
			shadowActive()
		}else{
			shadowInActive()
		}
	}
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
		
		if frameIsActive{
			myContent?.setActive()
			self.layer?.borderColor = NSColor(.sand4).cgColor
			self.layer?.backgroundColor = NSColor(.sand4).cgColor
			shadowActive()
			showHeader()
			self.resetCursorRects()
		}else{
		_ = myContent?.setInactive()
			self.layer?.borderColor = NSColor(.sand3).cgColor
			self.layer?.backgroundColor = NSColor(.sand3).cgColor
			shadowInActive()
			hideHeader()
			self.discardCursorRects()
		}
	}
	
	override func mouseDown(with event: NSEvent) {
		if !frameIsActive{
			niParentDoc?.setTopNiFrame(myController!)
			return
		}
		
		let cursorPos = self.convert(event.locationInWindow, from: nil)
		
		//enable drag and drop niFrame to new postion and resizing
		cursorOnBorder = isOnBoarder(cursorPos)
		cursorDownPoint = event.locationInWindow
		
		if (cursorOnBorder == .top){
			if(event.clickCount == 2){
				fillOrRetractView(with: event)
				return
			}
			NSCursor.closedHand.push()
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		if !frameIsActive{
			nextResponder?.mouseUp(with: event)
			return
		}
		
		if (cursorOnBorder == .top){
			NSCursor.pop()
		}

		cursorDownPoint = .zero
		cursorOnBorder = .no
		deactivateDocumentResize = false
		//TODO: look for a cleaner solution,- this is called here so the hand icon switches from closed to open
		resetCursorRects()
	}
	
	override func mouseDragged(with event: NSEvent) {
		if !frameIsActive{
			nextResponder?.mouseDragged(with: event)
			return
		}
		
		let currCursorPoint = event.locationInWindow
		let horizontalDistanceDragged = currCursorPoint.x - cursorDownPoint.x
		let verticalDistanceDragged = currCursorPoint.y - cursorDownPoint.y
		
		//Update here, so we don't have a frame running quicker then the cursor
		cursorDownPoint = currCursorPoint
		
		switch cursorOnBorder {
			case .topLeft:
				resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged, cursorLeftSide: true, cursorTop: true)
			case .topRight:
				resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged, cursorTop: true)
			case .top:
				repositionView(horizontalDistanceDragged, verticalDistanceDragged)
			case .bottomLeft:
				resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged, cursorLeftSide: true)
			case .bottom:
				resizeOwnFrame(0, verticalDistanceDragged)
			case .bottomRight:
				resizeOwnFrame(horizontalDistanceDragged, verticalDistanceDragged)
			case .leftSide:
				resizeOwnFrame(horizontalDistanceDragged, 0, cursorLeftSide: true)
			case .rightSide:
				resizeOwnFrame(horizontalDistanceDragged, 0)
		default:
				return
		}
	}
	
	override func resetCursorRects() {
		if(frameIsActive){
			//otherwise hand opens while dragging
			if(cursorDownPoint == .zero){
				addCursorRect(getTopBorderActionArea(), cursor: NSCursor.openHand)
				addCursorRect(getDragArea(), cursor: NSCursor.openHand)
			}
			addCursorRect(getRightSideBorderActionArea(), cursor: niLeftRightCursor)
			addCursorRect(getLeftSideBorderActionArea(), cursor: niLeftRightCursor)
			addCursorRect(getBottomBorderActionArea(), cursor: niUpDownCursor)
			
			//Corners Top
			addCursorRect(getTopLeftCornerActionAreaVertical(), cursor: niDiagonalCursor)
			addCursorRect(getTopLeftCornerActionAreaHorizontal(), cursor: niDiagonalCursor)
			
			addCursorRect(getTopRightCornerActionAreaVertical(), cursor: niDiagonalFlippedCursor)
			addCursorRect(getTopRightCornerActionAreaHorizontal(), cursor: niDiagonalFlippedCursor)
			
			//Corners Bottom
			addCursorRect(getBottomRightCornerActionAreaVertical(), cursor: niDiagonalCursor)
			addCursorRect(getBottomRightCornerActionAreaHorizontal(), cursor: niDiagonalCursor)
			
			addCursorRect(getBottomLeftCornerActionAreaVertical(), cursor: niDiagonalFlippedCursor)
			addCursorRect(getBottomLeftCornerActionAreaHorizontal(), cursor: niDiagonalFlippedCursor)
		}
	}
	
	func clickedMinimizeButton(with event: NSEvent){
		guard let myController = nextResponder as? ContentFrameController else{return}
		myController.minimizeClicked(event)
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
		if (NSPointInRect(cursorLocation, getTopBorderActionArea()) || NSPointInRect(cursorLocation, getDragArea())){
			return .top
		}
		return super.isOnBoarder(cursorLocation)
	}
	
	func changeFrameColor(set color: NSColor){
		self.layer?.backgroundColor = color.cgColor
		fillColor = color
		self.borderColor = color
		cfHeadView.wantsLayer = true
		cfHeadView.layer?.backgroundColor = color.cgColor
	}
	
	private func getDragArea() -> NSRect{
		return self.convert(cfHeadDragArea.frame, from: cfHeadView)
	}
	
	private func shadowActive(){
		
		self.clipsToBounds = false
		
		self.layer?.shadowColor = NSColor.sand115.cgColor
		self.layer?.shadowOffset = CGSize(width: 0.0, height: -1.0)
		self.layer?.shadowOpacity = 0.33
		self.layer?.shadowRadius = 3.0
		self.layer?.masksToBounds = false
		
		self.dropShadow2.removeFromSuperlayer()
		
		self.dropShadow2 = CALayer(layer: self.layer!)
		self.dropShadow2.shadowPath = NSBezierPath(rect: bounds).cgPath
		self.dropShadow2.shadowColor = NSColor.sand115.cgColor
		self.dropShadow2.shadowOffset = CGSize(width: 2.0, height: -4.0)
		self.dropShadow2.shadowOpacity = 0.2
		self.dropShadow2.shadowRadius = 6.0
		self.dropShadow2.masksToBounds = false
		
		self.layer?.insertSublayer(self.dropShadow2, at: 0)
		
		self.dropShadow3.removeFromSuperlayer()
		
		self.dropShadow3 = CALayer(layer: self.layer!)
		self.dropShadow3.shadowPath = NSBezierPath(rect: bounds).cgPath
		self.dropShadow3.shadowColor = NSColor.sand115.cgColor
		self.dropShadow3.shadowOffset = CGSize(width: 4.0, height: -8.0)
		self.dropShadow3.shadowOpacity = 0.2
		self.dropShadow3.shadowRadius = 20.0
		self.dropShadow3.masksToBounds = false
		
		dropShadow2.insertSublayer(self.dropShadow3, at: 0)
	}
	
	private func shadowInActive(){
		self.dropShadow2.removeFromSuperlayer()
		self.dropShadow3.removeFromSuperlayer()
		
		self.layer?.shadowColor = NSColor.sand9.cgColor
		self.layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
		self.layer?.shadowOpacity = 0.5
		self.layer?.shadowRadius = 1.0
		self.layer?.masksToBounds = false
	}
	
	private func hideHeader(){
		closeButton.tintInactive()
		minimizeButton.tintInactive()
		maximizeButton.tintInactive()
		cfGroupButton.tintInactive()
	}
	
	private func showHeader(){
		closeButton.tintActive()
		minimizeButton.tintActive()
		maximizeButton.tintActive()
		cfGroupButton.tintActive()
	}
	
	// MARK: - fwd/back button
	private func setUpFwdBackButton(){
		guard let niWebView = myContent as? NiWebView else { return }
		
		backButton.isHidden = false
		forwardButton.isHidden = false
		
		backButton.setMouseDownFunction(backButtonClicked)
		backButton.isActiveFunction = backButtonIsActive
		
		forwardButton.setMouseDownFunction(forwardButtonClicked)
		forwardButton.isActiveFunction = fwdButtonIsActive
		
		setWebViewObservers(niWebView)
	}
	
	private func setWebViewObservers(_ contentView: NiWebView){
		contentView.addObserver(self, forKeyPath: "canGoBack", options: [.initial, .new], context: nil)
		contentView.addObserver(self, forKeyPath: "canGoForward", options: [.initial, .new], context: nil)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let niWebView = myContent as? NiWebView else { return }
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
		guard let niWebView = myContent as? NiWebView else { return }
		niWebView.goForward()
	}
	
	func backButtonClicked(with event: NSEvent){
		guard let niWebView = myContent as? NiWebView else { return }
		niWebView.goBack()
	}
	
	func updateFwdBackTint(){
		self.setBackButtonTint(backButtonIsActive())
		self.setForwardButtonTint(fwdButtonIsActive())
	}
	
	func fwdButtonIsActive() -> Bool{
		guard let niWebView = myContent as? NiWebView else {return false}
		return niWebView.canGoForward
	}
	
	func backButtonIsActive() -> Bool{
		guard let niWebView = myContent as? NiWebView else {return false}
		return niWebView.canGoBack
	}
	
	@MainActor
	private func setBackButtonTint(_ canGoBack: Bool = false){
		if(canGoBack){
			self.backButton.contentTintColor = NSColor(.sand11)
		}else{
			self.backButton.contentTintColor = NSColor(.sand8)
		}
	}
	
	@MainActor
	private func setForwardButtonTint(_ canGoFwd: Bool = false){
		if(canGoFwd){
			self.forwardButton.contentTintColor = NSColor(.sand11)
		}else{
			self.forwardButton.contentTintColor = NSColor(.sand8)
		}
	}
	
	override func deinitSelf() {
		myContent?.spaceRemovedFromMemory()
		
		closeButton.setMouseDownFunction(nil)
		closeButton.isActiveFunction = nil
		closeButton.mouseDownInActiveFunction = nil
		
		maximizeButton.setMouseDownFunction(nil)
		maximizeButton.isActiveFunction = nil
		maximizeButton.mouseDownInActiveFunction = nil
		
		cfGroupButton.mouseDownFunction = nil
		cfGroupButton.mouseDownInActiveFunction = nil
		cfGroupButton.isActiveFunction = nil
		
		minimizeButton.setMouseDownFunction(nil)
		minimizeButton.isActiveFunction = nil
		minimizeButton.mouseDownInActiveFunction = nil
		
		super.deinitSelf()
	}
	
	deinit{
		print("called on simple View")
	}
}
