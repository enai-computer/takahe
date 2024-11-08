//
//  CFCollapsedMinimizedView.swift
//  ni
//
//  Created by Patrick Lukas on 16/9/24.
//

import Cocoa

class CFCollapsedMinimizedView: CFBaseView, CFHasGroupButtonProtocol, NiMouseDownHandler, CFHeadActionImageDelegate{
	
	@IBOutlet var cfGroupButton: CFGroupButton!
	@IBOutlet var cfHeadView: NSView!
	@IBOutlet var listOfTabs: NSStackView?
	@IBOutlet var maximizeButton: CFHeadActionImage!
	@IBOutlet var expandDownwardsButton: CFHeadActionImage!
	@IBOutlet var closeButton: CFHeadActionImage!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func initAfterViewLoad(nrOfItems: Int, groupName: String?){

		self.wantsLayer = true
		self.layer?.shadowColor = NSColor.sand9.cgColor
		self.layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
		self.layer?.shadowOpacity = 0.5
		self.layer?.shadowRadius = 1.0
		self.layer?.masksToBounds = false
	
		if(nrOfItems < 7){
			listOfTabs?.frame.size.width = (24.0 + 14.0) * CGFloat(nrOfItems) //+ 7.0
		}else{
			listOfTabs?.frame.size.width = (24.0 + 14.0) * 7.0 //+ 7.0
		}
		
		cfGroupButton.initButton(
			mouseDownFunction: clickedGroupButton,
			mouseDownInActiveFunction: activateContentFrame,
			isActiveFunction: self.isFrameActive,
			displayType: .minimised
		)
		cfGroupButton.setView(title: groupName)
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> CFBaseView.OnBorder {
		if(NSPointInRect(cursorLocation, cfHeadView.frame)){
			return .top
		}
		return .no
	}
	
	func expandButtonClicked(with event: NSEvent){
		myController?.minimizedToExpanded()
	}
	
	func expandDownwardsButtonClicked(with event: NSEvent){
		myController?.collapsedToMinimized()
	}
	
	override func mouseDown(with event: NSEvent) {
		if !frameIsActive{
			niParentDoc?.setTopNiFrame(myController!)
			return
		}
		let posInFrame = self.contentView?.convert(event.locationInWindow, from: nil)
		
		cursorOnBorder = isOnBoarder(posInFrame!)
		if cursorOnBorder != .no{
			cursorDownPoint = event.locationInWindow
		}
		
		if(cursorOnBorder == .top){
			NSCursor.closedHand.push()
		}
	}
	
	override func mouseDragged(with event: NSEvent) {
		if !frameIsActive{
			nextResponder?.mouseDragged(with: event)
			return
		}
		
		if cursorOnBorder != .top{
			return
		}
		let currCursorPoint = event.locationInWindow
		let horizontalDistanceDragged = currCursorPoint.x - cursorDownPoint.x
		let verticalDistanceDragged = currCursorPoint.y - cursorDownPoint.y
		
		//Update here, so we don't have a frame running quicker then the cursor
		cursorDownPoint = currCursorPoint
		
		repositionView(horizontalDistanceDragged, verticalDistanceDragged)
	}
	
	override func mouseUp(with event: NSEvent) {
		if !frameIsActive{
			nextResponder?.mouseUp(with: event)
			return
		}
		if cursorOnBorder == .top{
			NSCursor.pop()
		}
		cursorDownPoint = .zero
		cursorOnBorder = .no
		deactivateDocumentResize = false
	}
	
	func mouseUp(with event: NSEvent, for type: CFHeadButtonType) {
		switch(type){
			case .expand:
				expandButtonClicked(with: event)
				return
			case .maximize:
				expandDownwardsButtonClicked(with: event)
				return
			case .close:
				clickedCloseButton(with: event)
				return
			default:
				assertionFailure("button type not implemented")
				return
		}
	}
	
	func isButtonActive(_ type: CFHeadButtonType) -> Bool{
		super.isFrameActive()
	}
	
	func niLeftMouseDown(trigger: NSView, context: Any?) {
		if let pos: Int = context as? Int{
			myController?.minimizedToExpanded(pos)
		}
	}
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
		
		if frameIsActive{
			closeButton.tintActive()
			maximizeButton.tintActive()
			cfGroupButton.tintActive()
			expandDownwardsButton.tintActive()
			self.resetCursorRects()
			layer?.backgroundColor = NSColor.sand4.cgColor
			layer?.borderColor = NSColor.sand4.cgColor
			fillColor = .sand4
		}else{
			closeButton.tintInactive()
			maximizeButton.tintInactive()
			cfGroupButton.tintInactive()
			expandDownwardsButton.tintInactive()
			self.discardCursorRects()
			layer?.backgroundColor = NSColor.sand3.cgColor
			layer?.borderColor = NSColor.sand3.cgColor
			fillColor = .sand3
		}
		retinitItems(frameIsActive)
	}
	
	private func retinitItems(_ frameIsActive: Bool){
		for item in listOfTabs!.views{
			if let itemView = item as? NSTextField{
				if(frameIsActive){
					itemView.textColor = .sand115
				}else{
					itemView.textColor = NSColor(.sand8)
				}
			}
		}
	}
	
	override func resetCursorRects() {
		if(frameIsActive){
			//otherwise hand opens while dragging
			if(cursorDownPoint == .zero){
				addCursorRect(getDragCursorRect(), cursor: NSCursor.openHand)
			}
		}
	}
	
	override func deinitSelf(keepContentView: Bool = false) {
		cfGroupButton.deinitSelf()
		listOfTabs?.removeFromSuperviewWithoutNeedingDisplay()
		listOfTabs = nil
		super.deinitSelf()
	}
	
	private func getDragCursorRect() -> NSRect{
		let width = maximizeButton.frame.minX - cfGroupButton.frame.maxX
		return NSRect(x: cfGroupButton.frame.maxX, y: cfHeadView.frame.origin.y, width: width, height: cfHeadView.frame.height)
	}
}
