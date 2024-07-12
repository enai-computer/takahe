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


	func initAfterViewLoad(tab: TabViewModel){
		guard (tab.type == .pdf) else {
			fatalError("SimpleMinimizedView for \(tab.type) has not been implemented")
		}
		name.stringValue = tab.title
		if let pdfDoc = tab.data as? PDFDocument{
			let page = pdfDoc.getPageSafely(at: 0)
			thumbnail.image = page?.thumbnail(of: thumbnail.frame.size, for: .trimBox)
		}
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
			//TODO: expand to Simple frame
			return
		}
		
		let posInFrame = self.contentView?.convert(event.locationInWindow,
												   from: nil)
		cursorOnBorder = isOnBoarder(posInFrame!)
		if cursorOnBorder != .no{
			cursorDownPoint = event.locationInWindow
		}
		
		if(cursorOnBorder == .top){
			NSCursor.closedHand.push()
		}
	}
}
