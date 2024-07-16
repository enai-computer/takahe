//
//  CFSimpleFrameView.swift
//  ni
//
//  Created by Patrick Lukas on 4/7/24.
//

import Cocoa

class CFSimpleFrameView: CFBaseView{
	
	@IBOutlet var cfHeadView: ContentFrameHeadView!
	@IBOutlet var cfGroupButton: CFGroupButton!
	@IBOutlet var maximizeButton: NiActionImage!
	@IBOutlet var minimizeButton: NiActionImage!
	@IBOutlet var closeButton: NiActionImage!
	@IBOutlet var placeholderView: NSView!
	
	private var myContent: CFContentItem?
	
	private var dropShadow2 = CALayer()
	private var dropShadow3 = CALayer()
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.wantsLayer = true
	}
	
	func initAfterViewLoad(_ groupName: String?, titleChangedCallback: ((String)->Void)?){
		closeButton.mouseDownFunction = clickedCloseButton
		closeButton.isActiveFunction = self.isFrameActive
		closeButton.mouseDownInActiveFunction = activateContentFrame
		
		maximizeButton.mouseDownFunction = fillOrRetractView
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
		
		minimizeButton.mouseDownFunction = clickedMinimizeButton
		minimizeButton.isActiveFunction = self.isFrameActive
		minimizeButton.mouseDownInActiveFunction = activateContentFrame
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
				repositionView(horizontalDistanceDragged, verticalDistanceDragged)
		}
	}
	
	func clickedMinimizeButton(with event: NSEvent){
		guard let myController = nextResponder as? ContentFrameController else{return}
		myController.minimizeClicked(event)
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
}
