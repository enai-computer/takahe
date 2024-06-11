//
//  NiScroller.swift
//  ni
//
//  Created by Patrick Lukas on 17/5/24.
//

import Cocoa

class NiScroller: NSScroller{

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.alphaValue = 0.0
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		if(isHidden){
			return
		}
		NSColor.sand4.setFill()
		dirtyRect.fill()
		self.drawKnob()
	}
	
	override func drawKnob() {
		NSColor.birkin.setFill()
		var knobFrame = rect(for: .knob)
		knobFrame.origin.y = 0
		knobFrame.size.height = 2.0
		NSBezierPath.init(roundedRect: knobFrame, xRadius: 1, yRadius: 1).fill()
	}
	
	override class func scrollerWidth(for controlSize: NSControl.ControlSize, scrollerStyle: NSScroller.Style) -> CGFloat {
		return 2.0
	}
	
	override func updateTrackingAreas() {
		let hoverEffect = NSTrackingArea.init(rect: self.superview!.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
		self.superview!.addTrackingArea(hoverEffect)
	}
	
	override func mouseEntered(with event: NSEvent) {
		self.alphaValue = 1.0
	}
	
	override func mouseExited(with event: NSEvent) {
		self.alphaValue = 0.0
	}
}
