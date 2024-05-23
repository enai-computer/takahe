//
//  CFSoftDeletedView.swift
//  ni
//
//  Created by Patrick Lukas on 22/5/24.
//

import Cocoa

class CFSoftDeletedView: NSBox {

	var myController: ContentFrameController? = nil
	@IBOutlet var undoIcon: NSImageView!
	
	func setSelfController(_ con: ContentFrameController){
		self.myController = con
	}
	
	override func prepareForReuse() {
		myController = nil
	}
	
	func initAfterViewLoad(){
		wantsLayer = true
		layer?.cornerRadius = 10
		layer?.cornerCurve = .continuous
		layer?.borderWidth = 5
		layer?.borderColor = NSColor(.sandLight4).cgColor
		layer?.backgroundColor = NSColor(.sandLight4).cgColor
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		addTrackingArea(hoverEffectTrackingArea)
		
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 5.0
			self.animator().alphaValue = 0.0
		}, completionHandler: {
			self.myController!.confirmClose()
			self.myController = nil
			self.removeFromSuperview()
		})
	}
	
	override func mouseEntered(with event: NSEvent) {
		undoIcon.contentTintColor = NSColor.birkin
		layer?.speed = 0.0
	}
	
	override func mouseExited(with event: NSEvent) {
		undoIcon.contentTintColor = NSColor.sandLight11
		layer?.speed = 1.0
	}
	
	override func mouseDown(with event: NSEvent) {
		myController!.cancelCloseProcess()
		removeFromSuperview()
	}
}
