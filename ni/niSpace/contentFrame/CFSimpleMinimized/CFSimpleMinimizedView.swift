//
//  CFSimpleMinimizedView.swift
//  ni
//
//  Created by Patrick Lukas on 12/7/24.
//

import Cocoa
import PDFKit

class CFSimpleMinimizedView: CFBaseView{
	
	@IBOutlet var thumbnail: NSImageView!
	@IBOutlet var name: NSTextField!

	private var cursorClosedHandPushed = false
	
	override func awakeFromNib() {
		thumbnail.wantsLayer = true
		thumbnail.layer?.cornerRadius = 2.0
		thumbnail.layer?.cornerCurve = .continuous
		thumbnail.layer?.masksToBounds = true
	}

	func initAfterViewLoad(tab: TabViewModel){
		guard (tab.type == .pdf) else {
			fatalError("SimpleMinimizedView for \(tab.type) has not been implemented")
		}
		name.stringValue = tab.title
		if let pdfDoc = tab.data as? PDFDocument{
			let page = pdfDoc.getPageSafely(at: 0)
			thumbnail.image = page?.thumbnail(of: thumbnail.frame.size, for: .trimBox)
			if(thumbnail.image!.size.height < thumbnail.frame.height - 5){
				thumbnail.frame.size.height = thumbnail.image!.size.height + 2
			}
		}
	}
	
	override func toggleActive() {
		frameIsActive = !frameIsActive
		
		if(frameIsActive){
			highlight()
		}else{
			removeHighlight()
		}
		
		return
	}
	
	private func highlight(){
		thumbnail.layer?.borderWidth = 1.0
		thumbnail.layer?.borderColor = NSColor.birkinT50.cgColor
		name.textColor = NSColor.birkin
	}
	
	private func removeHighlight(){
		thumbnail.layer?.borderWidth = 0
		name.textColor = NSColor.sand115
	}
	
	override func isOnBoarder(_ cursorLocation: CGPoint) -> CFBaseView.OnBorder {
		if(NSPointInRect(cursorLocation, self.bounds)){
			return .top
		}
		return .no
	}
	
	override func mouseDown(with event: NSEvent) {
		if !frameIsActive{
			niParentDoc?.setTopNiFrame(myController!)
			return
		}
		
		if(event.clickCount == 2){
			maximize()
			return
		}
		
		let posInFrame = self.contentView?.convert(event.locationInWindow,
												   from: nil)
		cursorOnBorder = isOnBoarder(posInFrame!)
		if cursorOnBorder != .no{
			cursorDownPoint = event.locationInWindow
		}
		
	}
	
	override func mouseDragged(with event: NSEvent) {
		if !frameIsActive{
			nextResponder?.mouseDragged(with: event)
			return
		}

		NSCursor.closedHand.push()
		cursorClosedHandPushed = true

		let currCursorPoint = event.locationInWindow
		let horizontalDistanceDragged = currCursorPoint.x - cursorDownPoint.x
		let verticalDistanceDragged = currCursorPoint.y - cursorDownPoint.y
		
		//Update here, so we don't have a frame running quicker then the cursor
		cursorDownPoint = currCursorPoint
		
		repositionView(horizontalDistanceDragged, verticalDistanceDragged)
	}
	
	override func mouseUp(with event: NSEvent) {
		if(cursorClosedHandPushed){
			NSCursor.current.pop()
			NSCursor.arrow.push()
			cursorClosedHandPushed = false
		}
	}
	
	private func maximize(){
		guard let myController = nextResponder as? ContentFrameController else{return}
		myController.maximizeSelf()
	}
}
