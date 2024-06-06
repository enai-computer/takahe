//
//  NiMenuItemView.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

class NiMenuItemView: NSView{
	
	@IBOutlet var title: NSTextField!
	var isEnabled = true
	var mouseDownFunction: ((NSEvent) -> Void)?
	
	override func updateTrackingAreas() {
		let hoverEffect = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
		addTrackingArea(hoverEffect)
	}
	
	override func mouseEntered(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		wantsLayer = true
		layer?.backgroundColor = NSColor.sandLight4.cgColor
		layer?.cornerRadius = 8.0
		layer?.cornerCurve = .continuous
	}
	
	override func mouseExited(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		layer?.backgroundColor = NSColor.sandLight2.cgColor
	}
	
	override func mouseDown(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		mouseDownFunction?(event)
		superview?.superview?.removeFromSuperview()
	}
}
