//
//  CFSectionTitleView.swift
//  Enai
//
//  Created by Patrick Lukas on 3/12/24.
//

import Cocoa

class CFSectionTitleView: CFBaseView{
	
	private var overlay: NSView?
	
	@IBOutlet var sectionTitle: NSTextField!
	private var hoverEffect: NSTrackingArea? = nil
	
	func initAfterViewLoad(sectionName: String?, myController: CFProtocol){
		sectionTitle.stringValue = sectionName ?? "New section"
		
		self.myController = myController
		self.wantsLayer = true
	}
	
	func setUnderline(){
		let bottomBorder = NSView(frame: calcUnderlineFrame())
		bottomBorder.wantsLayer = true
		bottomBorder.layer?.backgroundColor = NSColor.sand115.cgColor
		self.addSubview(bottomBorder)
		
		bottomBorder.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			bottomBorder.leadingAnchor.constraint(equalTo: sectionTitle.leadingAnchor),
			bottomBorder.trailingAnchor.constraint(equalTo: sectionTitle.trailingAnchor),
		])
	}
	
	private func calcUnderlineFrame() -> CGRect{
		return CGRect(x: sectionTitle.frame.origin.x, y: (sectionTitle.frame.origin.y - 2.0), width: sectionTitle.frame.width, height: 2.0)
	}
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
	
		if(frameIsActive){
			setBorder()
			overlay?.removeFromSuperview()
			overlay = nil
			sectionTitle.isEditable = true
			window?.makeFirstResponder(self)
		}else{
			sectionTitle.isEditable = false
			sectionTitle.isSelectable = false
			
			overlay = SectionTitleOverlay(frame: sectionTitle.frame, nxtResponder: self)
			sectionTitle.addSubview(overlay!)
			sectionTitle.window?.makeFirstResponder(overlay)
			
			removeBorder()
		}
		updateTrackingAreas()
	}
	
	func setBorder(){
		borderColor = NSColor.birkin
	}
	
	func removeBorder(){
		borderColor = .transparent
	}
	
	/*
	 * MARK: mouse events here
	 */
	override func mouseDown(with event: NSEvent) {
		if !frameIsActive{
			niParentDoc?.setTopNiFrame(myController!)
			return
		}
		let posInFrame = self.contentView?.convert(event.locationInWindow, from: nil)
		
		cursorOnBorder = isOnBoarder(posInFrame!)
		cursorDownPoint = event.locationInWindow
		
		if(cursorOnBorder == .top ||  cursorOnBorder == .bottom){
			NSCursor.closedHand.push()
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
			case .top:
				repositionView(horizontalDistanceDragged, verticalDistanceDragged)
			case .leftSide:
				resizeOwnFrame(horizontalDistanceDragged, 0, cursorLeftSide: true, enforceMinHeight: false)
			case .rightSide:
				resizeOwnFrame(horizontalDistanceDragged, 0, enforceMinHeight: false)
			default:
				repositionView(horizontalDistanceDragged, verticalDistanceDragged)
		}
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
		super.resizeOwnFrame(xDiff, yDiff, cursorLeftSide: invertX, cursorTop: invertY, enforceMinHeight: enforceMinHeight)
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
		if (NSPointInRect(cursorLocation, getTopBorderActionArea())) {
			return .top
		}
		if(NSPointInRect(cursorLocation, getBottomBorderActionArea())){
			return .bottom
		}
		if(NSPointInRect(cursorLocation, getLeftSideBorderActionArea())){
			return .leftSide
		}
		if(NSPointInRect(cursorLocation, getRightSideBorderActionArea())){
			return .rightSide
		}
		return .no
	}
	
	override func keyDown(with event: NSEvent){
		super.keyDown(with: event)
	}
	
	/*
	 * MARK: cursor rects
	 */
	private let topBorderActionMargin: CGFloat = 8.0
	private let bottomBorderActionMargin: CGFloat = 10.0
	private let borderSideActionMargin: CGFloat = 12.0
	
	override func resetCursorRects() {
		if(frameIsActive){
			//otherwise hand opens while dragging
			if(cursorDownPoint == .zero){
				addCursorRect(getTopBorderActionArea(), cursor: NSCursor.openHand)
				addCursorRect(getBottomBorderActionArea(), cursor: NSCursor.openHand)
			}
			addCursorRect(getRightSideBorderActionArea(), cursor: niLeftRightCursor)
			addCursorRect(getLeftSideBorderActionArea(), cursor: niLeftRightCursor)
		}
	}
	
	override func getTopBorderActionArea() -> NSRect{
		return NSRect(x: borderSideActionMargin, y: frame.size.height-topBorderActionMargin, width: (frame.size.width - borderSideActionMargin * 2.0), height: topBorderActionMargin)
	}
	
	override func getBottomBorderActionArea() -> NSRect{
		return NSRect(x: borderSideActionMargin, y: 0, width: (frame.size.width - borderSideActionMargin * 2.0), height: bottomBorderActionMargin)
	}
	
	
	override func getLeftSideBorderActionArea() -> NSRect{
		return NSRect(x:0, y: 0, width: borderSideActionMargin, height: frame.size.height)
	}
	
	override func getRightSideBorderActionArea() -> NSRect{
		return NSRect(x: (frame.size.width - borderSideActionMargin), y: 0, width: borderSideActionMargin, height: frame.size.height)
	}
	
}
