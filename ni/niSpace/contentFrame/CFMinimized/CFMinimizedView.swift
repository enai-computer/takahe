//
//  CFMinimizedView.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//

import Cocoa

class CFMinimizedView: CFBaseView{
	
	
	@IBOutlet var cfGroupButton: CFGroupButton!
	@IBOutlet var cfHeadView: NSView!
	@IBOutlet var listOfTabs: NSStackView?
	@IBOutlet var maximizeButton: NiActionImage!
	@IBOutlet var closeButton: NiActionImage!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func initAfterViewLoad(nrOfItems: Int, groupName: String?){
		frame.size.height = Double(nrOfItems) * 39.0 + 36.0
		
		self.wantsLayer = true
		self.layer?.shadowColor = NSColor.sand9.cgColor
		self.layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
		self.layer?.shadowOpacity = 0.5
		self.layer?.shadowRadius = 1.0
		self.layer?.masksToBounds = false
		
		closeButton.mouseDownFunction = clickedCloseButton
		closeButton.isActiveFunction = self.isFrameActive
		closeButton.mouseDownInActiveFunction = activateContentFrame
		
		maximizeButton.mouseDownFunction = maximizeButtonClicked
		maximizeButton.isActiveFunction = self.isFrameActive
		maximizeButton.mouseDownInActiveFunction = activateContentFrame
		
		cfGroupButton.initButton(
			mouseDownFunction: clickedGroupButton,
			mouseDownInActiveFunction: activateContentFrame,
			isActiveFunction: self.isFrameActive
		)
		cfGroupButton.setView(title: groupName)
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> CFBaseView.OnBorder {
		if(NSPointInRect(cursorLocation, cfHeadView.frame)){
			return .top
		}
		return .no
	}
	
	func maximizeButtonClicked(with event: NSEvent){
		guard let myController = nextResponder as? ContentFrameController else{return}
		myController.minimizedToExpanded()
		return
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
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
		
		if frameIsActive{
			closeButton.tintActive()
			maximizeButton.tintActive()
			cfGroupButton.tintActive()
			self.resetCursorRects()
		}else{
			closeButton.tintInactive()
			maximizeButton.tintInactive()
			cfGroupButton.tintInactive()
			self.discardCursorRects()
		}
		retinitItems(frameIsActive)
	}
	
	private func retinitItems(_ frameIsActive: Bool){
		for item in listOfTabs!.views{
			if let itemView = item as? CFMinimizedStackItem{
				itemView.updateTextTint(frameIsActive)
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
	
	private func getDragCursorRect() -> NSRect{
		let width = cfHeadView.frame.width - closeButton.frame.width - maximizeButton.frame.width - cfGroupButton.frame.width
		return NSRect(x: cfGroupButton.frame.maxX, y: cfHeadView.frame.origin.y, width: width, height: cfHeadView.frame.height)
	}
}
