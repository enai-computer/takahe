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

	func initAfterViewLoad(sectionName: String?, myController: CFProtocol){
		sectionTitle.stringValue = "TEST NAME"//sectionName ?? ""
		
		self.myController = myController
		self.wantsLayer = true
		self.layer?.addSublayer(bottomBorder())
	}
	
	private func bottomBorder() -> CALayer{
		let bottomBorder = CALayer(layer: layer!)
		bottomBorder.borderColor = NSColor.sand115.cgColor
		bottomBorder.borderWidth = 2.0
		bottomBorder.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 2.0)
		return bottomBorder
	}
	
	override func toggleActive(){
		frameIsActive = !frameIsActive
	
		if(frameIsActive){
			setBorder()
			overlay?.removeFromSuperview()
			overlay = nil
			sectionTitle.isEditable = true
			layer?.borderColor = NSColor.sand2.cgColor
		}else{
			sectionTitle.isEditable = false
			sectionTitle.isSelectable = false
			
			overlay = SectionTitleOverlay(frame: sectionTitle.frame, nxtResponder: self)
			sectionTitle.addSubview(overlay!)
			sectionTitle.window?.makeFirstResponder(overlay)
			
			layer?.borderColor = NSColor.clear.cgColor
			
			removeBorder()
		}
		updateTrackingAreas()
	}
	
	func setBorder(){
		borderColor = NSColor.birkinLight
		borderWidth = 2.0
	}
	
	func removeBorder(){
		borderWidth = 0.0
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
}
