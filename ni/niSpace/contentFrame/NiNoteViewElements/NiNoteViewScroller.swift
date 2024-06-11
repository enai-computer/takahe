//
//  NiNoteViewScroller.swift
//  ni
//
//  Created by Patrick Lukas on 4/6/24.
//

import Cocoa

class NiNoteViewScroller: NSScroller{

	private var hideKnob = true

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		NSColor.sand4.setFill()
		dirtyRect.fill()

		self.drawKnob()
	}
	
	override func drawKnob() {
		if(hideKnob){
			NSColor.sand4.setFill()
		}else{
			NSColor.birkin.setFill()
		}
		
		var knobFrame = rect(for: .knob)
		knobFrame.origin.x = 0
		knobFrame.size.width = 2.0
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
