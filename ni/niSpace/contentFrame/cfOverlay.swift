//
//  cfOverlay.swift
//  ni
//
//  Created by Patrick Lukas on 9/4/24.
//

import Cocoa

class cfOverlay: NSView{
	
	//We want to skipp over a few responders here
	private var niNxtResponder: NSResponder?
	
	init(frame: NSRect, nxtResponder: NSResponder?){
		super.init(frame: frame)
		self.niNxtResponder = nxtResponder
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func draw(_ dirtyRect: NSRect){
		NSColor.overlay.setFill()
		NSBezierPath(rect: CGRect(x: dirtyRect.origin.x, y: dirtyRect.origin.y, width: dirtyRect.size.width, height: dirtyRect.size.height)).fill()
	}
	
	override func mouseDown(with event: NSEvent) {
		niNxtResponder?.mouseDown(with: event)
	}
	
	override func mouseUp(with event: NSEvent) {
		
	}
	
	override func mouseDragged(with event: NSEvent) {
		
	}
	
	override func mouseEntered(with event: NSEvent) {
		
	}
	
	override func mouseExited(with event: NSEvent) {
		
	}
	
	override func mouseMoved(with event: NSEvent) {
		
	}
	
	override func rightMouseDown(with event: NSEvent) {
		
	}
	
	override func rightMouseUp(with event: NSEvent) {
		
	}
	
	override func rightMouseDragged(with event: NSEvent) {
		
	}
	
}
