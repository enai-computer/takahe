//
//  cfOverlay.swift
//  ni
//
//  Created by Patrick Lukas on 9/4/24.
//

import Cocoa

class cfOverlay: NSView{
	
	override func draw(_ dirtyRect: NSRect){
		NSColor.overlay.setFill()
		NSBezierPath(rect: CGRect(x: dirtyRect.origin.x, y: dirtyRect.origin.y, width: dirtyRect.size.width, height: dirtyRect.size.height)).fill()
	}
	
	override func mouseDown(with event: NSEvent) {
		//TODO: make this CF active 
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
