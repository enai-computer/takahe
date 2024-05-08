//
//  CFMinimizedView.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//

import Cocoa

class CFMinimizedView: CFBaseView{
	
	
	@IBOutlet var cfHeadView: NSView!
	@IBOutlet var listOfTabs: NSStackView?
	@IBOutlet var maximizeButton: NSImageView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		//FIXME: on init listOfTabs is nil, so we never set the cornerRadius
		listOfTabs?.wantsLayer = true
		listOfTabs?.layer?.cornerRadius = 10
		listOfTabs?.layer?.cornerCurve = .continuous
	}
	
	func setHight(nrOfItems: Int){
		frame.size.height = Double(nrOfItems) * 50.0 + 36.0
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> CFBaseView.OnBorder {
		if(NSPointInRect(cursorLocation, cfHeadView.frame)){
			return .top
		}
		return .no
	}
	
	override func mouseDown(with event: NSEvent) {
		let posInFrame = self.contentView?.convert(event.locationInWindow, from: nil)
		let posInHeadView = self.cfHeadView.convert(event.locationInWindow, from: nil)
		
		if(NSPointInRect(posInHeadView, maximizeButton.frame)){
			guard let myController = nextResponder as? ContentFrameController else{return}
			myController.minimizedToExpanded()
		}
		
		cursorOnBorder = isOnBoarder(posInFrame!)
		if cursorOnBorder != .no{
			cursorDownPoint = event.locationInWindow
		}
		
		if(cursorOnBorder == .top){
			NSCursor.closedHand.push()
		}
	}
	
	override func mouseDragged(with event: NSEvent) {
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
		if cursorOnBorder == .top{
			NSCursor.pop()
		}
		cursorDownPoint = .zero
		cursorOnBorder = .no
		deactivateDocumentResize = false
	}
}
