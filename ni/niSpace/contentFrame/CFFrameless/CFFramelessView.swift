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
	var myItem: CFContentItem?
	private var myItemType: TabContentType? = nil
	
	override var frameType: NiContentFrameState {return .frameless}
	
	private var hoverEffect: NSTrackingArea? = nil
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
	
		if(frameIsActive){
			setBorder()
			myItem?.setActive()
		}else{
			if(myItem?.setInactive() == .removeSelf){
				blanketCFC?.confirmClose()
			}
			removeBorder()
		}
		updateTrackingAreas()
	}
	
	func removeBorder(){
		if(myItemType == .note){
			self.borderColor = NSColor.sand1
		}else if(myItemType == .sticky){
			self.borderColor = .transparent
		}else{
			self.borderColor = NSColor.sand3
		}
		shadow = nil
	}
	
	func setBorder(){
		if(myItemType == .note || myItemType == .sticky){
			wantsLayer = true
			shadow = NSShadow()
			layer?.shadowOffset = CGSize(width: 2.0, height: -4.0)
			layer?.shadowColor = NSColor.sand11.cgColor
			layer?.shadowRadius = 6.0
			layer?.shadowOpacity = 0.3
		}
		
		if (myItemType == .note){
			borderColor = NSColor.sand1
		}else if(myItemType == .sticky){
			borderColor = .transparent
			borderWidth = 0.0
		}else{
			self.borderColor = NSColor.birkin
			shadow = nil
		}
	}
	
	func setContentItem(item: CFContentItem, of type: TabContentType? = nil){
		self.myItem = item
		if let type: TabContentType = type{
			self.myItemType = type
		}
	}
	
	/** If the passed view does not confirm to CFContentItem, you have to call setContentItem speratly!
	 
	 */
	override func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int{
		self.contentView = tabView
		if let item = tabView as? CFContentItem{
			setContentItem(item: item)
		}
		self.contentView?.layer?.cornerCurve = .continuous
		self.contentView?.layer?.cornerRadius = 5.0
		return 0
	}
	
	@discardableResult
	func createNewTab(tabView: NSView, openNextTo: Int = -1, of type: TabContentType) -> Int{
		self.myItemType = type
		return createNewTab(tabView: tabView, openNextTo: openNextTo)
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete){
			if(frameIsActive){
				myController?.triggerCloseProcess(with: event)
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
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
		if(myItemType == .sticky){
			return .no
		}
		return super.isOnBoarder(cursorLocation)
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
		if(!frameIsActive && myItemType != .sticky){
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
		guard myItemType != .sticky else {return}
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
	
	override func resizeOwnFrame(_ xDiff: Double, _ yDiff: Double, cursorLeftSide invertX: Bool = false, cursorTop invertY: Bool = false, enforceMinHeight: Bool = true){
		super.resizeOwnFrame(xDiff, yDiff, cursorLeftSide: invertX, cursorTop: invertY)
		
		//called so that we don't get white space below a short note
		if let noteItem = myItem as? NiNoteItem{
			noteItem.resizeContent()
		}
	}
	
	override func deinitSelf(keepContentView: Bool = false) {
		if(!keepContentView){
			myItem?.spaceRemovedFromMemory()
			myItem = nil
		}
		super.deinitSelf()
	}
	
}
