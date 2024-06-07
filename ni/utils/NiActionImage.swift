//
//  NiActionImage.swift
//  ni
//
//  Created by Patrick Lukas on 29/4/24.
//

import Cocoa


class NiActionImage: NSImageView{
	
	var mouseDownFunction: ((NSEvent) -> Void)?
	var mouseDownInActiveFunction: ((NSEvent) -> Void)?
	var isActiveFunction: (() -> Bool)?

	init(image: NSImage){
		super.init(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: image.size))
		self.image = image
		
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}
	
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
		self.contentTintColor = NSColor(.birkin)
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
		self.contentTintColor = NSColor(.sandLight8)
	}
	
	func tintActive(){
		self.contentTintColor = NSColor(.sandLight11)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		mouseDownFunction = nil
		isActiveFunction = nil
	}
}
