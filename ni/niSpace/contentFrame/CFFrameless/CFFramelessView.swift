//
//  CFFramelessView.swift
//  ni
//
//  Created by Patrick Lukas on 26/5/24.
//

import Cocoa
import Carbon.HIToolbox

class CFFramelessView: CFBaseView {
	
	override var minFrameHeight: CGFloat {return 50.0}
	override var minFrameWidth: CGFloat {return 80.0}
	var myView: CFContentItem? {return contentView as? CFContentItem}
	
	private var hoverEffect: NSTrackingArea? = nil
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
	
		if(frameIsActive){
			myView?.setActive()
			updateTrackingAreas()
			setBorder()
		}else{
			if(myView?.setInactive() == .removeSelf){
				myController?.confirmClose()
			}
			updateTrackingAreas()
			removeBorder()
		}
	}
	
	func removeBorder(){
		self.borderColor = NSColor.sandLight3
	}
	
	func setBorder(){
		self.borderColor = NSColor.birkin
	}
	
	func setContentView(view: NSView){
		self.contentView = view
	}
	
	override func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int{
		self.contentView = tabView
		self.contentView?.layer?.cornerCurve = .continuous
		self.contentView?.layer?.cornerRadius  = 5.0
		return -1
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete){
			if(frameIsActive){
				myView?.owner?.triggerCloseProcess(with: event)
				return
			}
		}
		super.keyDown(with: event)
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
	
	override func mouseEntered(with event: NSEvent) {
		if(!frameIsActive){
			borderColor = NSColor.birkinLight
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		if(!frameIsActive){
			removeBorder()
		}
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
	
	override func resetCursorRects() {
		if(frameIsActive){
			//otherwise hand opens while dragging
			if(cursorDownPoint == .zero){
				addCursorRect(getTopBorderActionArea(), cursor: NSCursor.openHand)
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
	
	override func updateTrackingAreas() {
		if let trackingArea = self.hoverEffect{
			removeTrackingArea(trackingArea)
		}
		
		if(!frameIsActive){
			hoverEffect = NSTrackingArea(rect: bounds,
										 options: [.activeInKeyWindow, .mouseEnteredAndExited],
										 owner: self,
										 userInfo: nil)
			addTrackingArea(hoverEffect!)
		}
	}
}
