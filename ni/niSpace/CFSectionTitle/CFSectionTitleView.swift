//
//  CFSectionTitleView.swift
//  Enai
//
//  Created by Patrick Lukas on 3/12/24.
//

import Cocoa
import Carbon.HIToolbox

class CFSectionTitleView: CFBaseView{
	
	private var overlay: NSView?
	
	@IBOutlet var sectionTitle: NSTextField!
	private var hoverEffect: NSTrackingArea? = nil
	
	
	func initAfterViewLoad(sectionName: String?, myController: CFProtocol){
		sectionTitle.stringValue = "TEST NAME"//sectionName ?? ""
		
		self.myController = myController
		self.wantsLayer = true
	}
	
	func setUnderline(){
		let bottomBorder = underlineLayer()
		self.layer?.addSublayer(bottomBorder)
	}
	
	private func underlineLayer() -> CALayer{
		let bottomBorder = CALayer(layer: layer!)
		bottomBorder.borderColor = NSColor.sand115.cgColor
		bottomBorder.borderWidth = 2.0
		bottomBorder.frame = CGRect(x: sectionTitle.frame.origin.x, y: (sectionTitle.frame.origin.y - 2.0), width: sectionTitle.frame.width, height: 2.0)
		return bottomBorder
	}
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
	
		if(frameIsActive){
			setBorder()
			overlay?.removeFromSuperview()
			overlay = nil
			sectionTitle.isEditable = true

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
	
	/*
	 * MARK: key events here
	 */
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete){
			if(frameIsActive){
				myController?.triggerCloseProcess(with: event)
				return
			}
		}
		super.keyDown(with: event)
	}
}
