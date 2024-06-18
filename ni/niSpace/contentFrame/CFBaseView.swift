//
//  CFBaseView.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//
import Cocoa

let minContentFrameExposure: CGFloat = 150

/** Base class shared by all ContentFrame Classes.
	Implements common functionality.
 
	Only inherite this class if your View is controlled by ContentFrameController. Do not use this class directly.
 */
class CFBaseView: NSBox{
	
	var niParentDoc: NiSpaceDocumentView? = nil
	var myController: ContentFrameController? = nil
	
	var fixedFrameRatio: Bool = false
	var frameIsActive: Bool = false
	var deactivateDocumentResize: Bool = false
	var cursorOnBorder: OnBorder = .no
	var cursorDownPoint: CGPoint  = .zero
	
	var minFrameHeight: CGFloat { return 150.0}
	var minFrameWidth: CGFloat { return 350.0}
	
	struct CFConstants {
		// const needed for resizing:
		static let actionAreaMargin: CGFloat = 8.0
		static let cornerActionAreaMargin: CGFloat = 24.0
	 }

	
	func setFrameOwner(_ owner: NiSpaceDocumentView!){
		self.niParentDoc = owner
	}
	
	func setSelfController(_ con: ContentFrameController){
		self.myController = con
	}
	
	func isFrameActive() -> Bool{
		return frameIsActive
	}
	
	func activateContentFrame(with event: NSEvent){
		if !frameIsActive{
			niParentDoc?.setTopNiFrame(myController!)
			return
		}
	}
	
	func clickedCloseButton(with event: NSEvent){
		myController!.triggerCloseProcess(with: event)
	}
	
	func clickedGroupButton(with event: NSEvent){
		myController!.showDropdown(with: event)
	}
	
	/**
	 Do not call this function within a save method, as it modifies the data-structure up the chain.
	 */
	func closedContentFrameCleanUp(){
		myController!.purgePersistetContent()
		niParentDoc?.removeNiFrame(myController!)
		removeFromSuperview()
	}
	
	func isOnBoarder(_ cursorLocation: CGPoint) -> OnBorder{
		let cAA = CFConstants.cornerActionAreaMargin
		
		if (NSPointInRect(cursorLocation, getTopBorderActionArea())) {
			return .top
		}
		
		if (NSPointInRect(cursorLocation, getTopLeftCornerActionAreaVertical()) || NSPointInRect(cursorLocation, getTopLeftCornerActionAreaHorizontal())){
			return .topLeft
		}
		
		if(NSPointInRect(cursorLocation, getTopRightCornerActionAreaVertical()) || NSPointInRect(cursorLocation, getTopRightCornerActionAreaHorizontal())){
			return .topRight
		}
		
		if ((0 < cursorLocation.y && cursorLocation.y < cAA) &&
			(frame.size.width - cAA < cursorLocation.x && cursorLocation.x < frame.size.width)){
			return .bottomRight
		}

		if ((0 < cursorLocation.y && cursorLocation.y < cAA) &&
			(0 < cursorLocation.x && cursorLocation.x < cAA)){
			return .bottomLeft
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
	
	func toggleActive(){
		preconditionFailure("This method must be overridden")
	}

	/** Will return -1 if view does not have tabs.
	 
	 */
	func createNewTab(tabView: NSView, openNextTo: Int = -1) -> Int{
		preconditionFailure("This method must be overridden")
	}
	
	enum OnBorder{
		case no, topLeft, top, topRight, bottomLeft, bottom, bottomRight, leftSide, rightSide
	}
	
	/*
	 * MARK: reposition and resize here. To be called by mouseDragged functions
	 */
	func repositionView(_ xDiff: Double, _ yDiff: Double) {
		
		let docW = self.niParentDoc!.frame.size.width
		let docHeight = self.niParentDoc!.frame.size.height
		
		//checks for out of bounds
		if(frame.origin.x + xDiff < maxZero(-(frame.width - minContentFrameExposure))){
			//Do nothing FIXME: clean up method
		}else if (frame.origin.x + xDiff + minContentFrameExposure < docW){
			frame.origin.x += xDiff
		}else if (xDiff < 0){ //moving to the left getting the Frame out of bounds
			frame.origin.x += xDiff
		}
		// do nothing when trying to move to far to the right
		
		if (frame.origin.y - yDiff < 45){	//45px is the hight of the top bar + shadow - FIXME: write cleaner implemetation
			frame.origin.y = 45
		}else if(frame.origin.y - yDiff + frame.height > docHeight){
			
			if(!deactivateDocumentResize && yDiff < 0){ //mouse moving downwards, not upwards
				self.niParentDoc!.extendDocumentDownwards()
				deactivateDocumentResize = true     //get's activated again when mouse lifted
			}else{
				frame.origin.y -= yDiff
			}

		}else{
			frame.origin.y -= yDiff
		}
	}
	
	private func maxZero(_ v: CGFloat) -> CGFloat{
		if(0.0 < v){
			return .zero
		}
		return v
	}
	
	func resizeOwnFrame(_ xDiff: Double, _ yDiff: Double, cursorLeftSide invertX: Bool = false, cursorTop invertY: Bool = false){
		let frameSize = frame.size
		var nsize = frameSize
		
		if(invertX){
			nsize.width -= xDiff
		}else{
			nsize.width += xDiff
		}
		if(invertY){
			nsize.height += yDiff
		}else{
			nsize.height -= yDiff
		}
		
		//enforcing min CF size
		if(nsize.height < minFrameHeight){
			nsize.height = minFrameHeight
		}
		if(nsize.width < minFrameWidth){
			nsize.width = minFrameWidth
		}
		
		let ratio = frame.size.width / frame.size.height
		if(fixedFrameRatio && ratio.isNormal){
			let posXDiff = xDiff.negateIfNegative()
			let posYDiff = yDiff.negateIfNegative()
			//higher mouse distance dictates scaling priority
			if(posXDiff < posYDiff){
				nsize.width = nsize.height * ratio
			}else{
				nsize.height = nsize.width / ratio
			}
		}

		//doesn't move if size did not change
		if(invertX && frame.size.width != nsize.width){
			self.frame.origin.x += xDiff
		}
		
		if(invertY && frame.size.height != nsize.height){
			self.frame.origin.y -= yDiff
		}
		self.setFrameSize(nsize)
	}
	
	/*
	 * MARK: border action area calc here
	 */
	func getTopBorderActionArea() -> NSRect{
		return NSRect(x: CFConstants.cornerActionAreaMargin, y: frame.size.height-CFConstants.actionAreaMargin, width: (frame.size.width - CFConstants.cornerActionAreaMargin * 2.0), height: CFConstants.actionAreaMargin)
	}
	
	func getBottomBorderActionArea() -> NSRect{
		return NSRect(x:CFConstants.cornerActionAreaMargin, y: 0, width: (frame.size.width - CFConstants.cornerActionAreaMargin * 2.0), height: CFConstants.actionAreaMargin)
	}
	
	func getLeftSideBorderActionArea() -> NSRect{
		return NSRect(x:0, y:CFConstants.cornerActionAreaMargin, width: CFConstants.actionAreaMargin, height: (frame.size.height - CFConstants.cornerActionAreaMargin * 2.0))
	}
	
	func getRightSideBorderActionArea() -> NSRect{
		return NSRect(x: (frame.size.width - CFConstants.actionAreaMargin), y: CFConstants.cornerActionAreaMargin, width: CFConstants.actionAreaMargin, height: (frame.size.height - CFConstants.cornerActionAreaMargin * 2.0))
	}

	func getTopRightCornerActionAreaVertical() -> NSRect{
		return NSRect(x: (frame.size.width - CFConstants.actionAreaMargin) , y: (frame.height - CFConstants.cornerActionAreaMargin), width: CFConstants.actionAreaMargin, height: CFConstants.cornerActionAreaMargin)
	}
	
	func getTopRightCornerActionAreaHorizontal() -> NSRect{
		return NSRect(x: (frame.size.width - CFConstants.cornerActionAreaMargin), y: (frame.height - CFConstants.actionAreaMargin), width: CFConstants.cornerActionAreaMargin, height: CFConstants.actionAreaMargin)
	}
	
	func getTopLeftCornerActionAreaVertical() -> NSRect{
		return NSRect(x: 0, y: (frame.height - CFConstants.cornerActionAreaMargin), width: CFConstants.actionAreaMargin, height: CFConstants.cornerActionAreaMargin)
	}
	
	func getTopLeftCornerActionAreaHorizontal() -> NSRect{
		return NSRect(x: 0.0, y: (frame.height - CFConstants.actionAreaMargin), width: CFConstants.cornerActionAreaMargin, height: CFConstants.actionAreaMargin)
	}
	
	func getBottomRightCornerActionAreaVertical() -> NSRect{
		return NSRect(x: (frame.size.width - CFConstants.actionAreaMargin) , y: 0.0, width: CFConstants.actionAreaMargin, height: CFConstants.cornerActionAreaMargin)
	}
	
	func getBottomRightCornerActionAreaHorizontal() -> NSRect{
		return NSRect(x: (frame.size.width - CFConstants.cornerActionAreaMargin), y: 0.0, width: CFConstants.cornerActionAreaMargin, height: CFConstants.actionAreaMargin)
	}
	
	func getBottomLeftCornerActionAreaVertical() -> NSRect{
		return NSRect(x: 0.0, y: 0.0, width: CFConstants.actionAreaMargin, height: CFConstants.cornerActionAreaMargin)
	}
	
	func getBottomLeftCornerActionAreaHorizontal() -> NSRect{
		return NSRect(x: 0.0, y: 0.0, width: CFConstants.cornerActionAreaMargin, height: CFConstants.actionAreaMargin)
	}
}
