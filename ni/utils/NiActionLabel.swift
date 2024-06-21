//
//  NiActionLabel.swift
//  ni
//
//  Created by Patrick Lukas on 21/6/24.
//

import Cocoa

class NiActionLabel: NSTextField{
	
	var mouseDownFunction: ((NSEvent) -> Void)?
	var mouseDownInActiveFunction: ((NSEvent) -> Void)?
	var isActiveFunction: (() -> Bool)?

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}
	
	override func mouseDown(with event: NSEvent) {
		//if is not active - don't change color
		if(isActiveFunction != nil && !isActiveFunction!()){
			mouseDownInActiveFunction?(event)
			return
		}
		mouseDownFunction?(event)
	}
	
	override func mouseEntered(with event: NSEvent) {
		//if is not active - don't change color
		if(isActiveFunction != nil && !isActiveFunction!()){
			return
		}
		self.textColor = NSColor(.birkin)
	}
	
	override func mouseExited(with event: NSEvent) {
		//if is not active - don't change color
		if(isActiveFunction != nil && !isActiveFunction!()){
			self.tintInactive()
			return
		}
		self.tintActive()
	}
	
	func tintInactive(){
		self.textColor = NSColor(.sand8)
	}
	
	func tintActive(){
		self.textColor = NSColor(.sand11)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		mouseDownFunction = nil
		isActiveFunction = nil
	}
}
