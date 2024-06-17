//
//  NiSearchViewScroller.swift
//  ni
//
//  Created by Patrick Lukas on 17/6/24.
//


import Cocoa

class NiSearchViewScroller: NSScroller{

	private var hideKnob = true

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		self.drawKnob()
	}
	
	override func drawKnob() {
		if(hideKnob){
			NSColor.transparent.setFill()
		}else{
			NSColor.birkin.setFill()
		}
		
		var knobFrame = rect(for: .knob)
		knobFrame.origin.x = 0
		knobFrame.size.width = 3.0
		NSBezierPath(rect: knobFrame).fill()
	}
	
	override class func scrollerWidth(for controlSize: NSControl.ControlSize, scrollerStyle: NSScroller.Style) -> CGFloat {
		return 3.0
	}
	
	override func updateTrackingAreas() {
		let hoverEffect = NSTrackingArea.init(rect: self.superview!.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
		self.superview!.addTrackingArea(hoverEffect)
	}
	
	override func mouseEntered(with event: NSEvent) {
		unhide()
	}
	
	override func mouseExited(with event: NSEvent) {
		hide()
	}
	
	func unhide(){
		hideKnob = false
		//needsDisplay is on purpose not called,
		//as we want to show the scroller only when used
	}
	
	func hide(){
		hideKnob = true
		needsDisplay = true
	}
}
