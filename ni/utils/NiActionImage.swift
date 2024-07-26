//
//  NiActionImage.swift
//  ni
//
//  Created by Patrick Lukas on 29/4/24.
//

import Cocoa


class NiActionImage: NSImageView{
	
	private var mouseDownFunction: ((NSEvent) -> Void)?
	private var mouseDownFunctionWContext: ((NSEvent, Any) -> Void)?
	var mouseDownInActiveFunction: ((NSEvent) -> Void)?
	var isActiveFunction: (() -> Bool)?
	private var clickContext: Any?
	
	@IBInspectable public var defaultTint: NSColor = .sand11
	
	private var prevDefaultTint: NSColor?
	
	init(image: NSImage, with size: NSSize? = nil){
		if(size == nil){
			super.init(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: image.size))
		}else{
			super.init(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: size!))
		}
		self.image = image
		
		if(size != nil){
			self.image?.size = size!
		}
		
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
		if(clickContext != nil){
			mouseDownFunctionWContext?(event, clickContext as Any)
			return
		}
		mouseDownFunction?(event)
	}
	
	override func mouseEntered(with event: NSEvent) {
		//if is not active - don't change color
		if(isActiveFunction != nil && !isActiveFunction!()){
			return
		}
		prevDefaultTint = self.contentTintColor
		self.contentTintColor = NSColor(.birkin)
	}
	
	override func mouseExited(with event: NSEvent) {
		//if is not active - don't change color
		if(isActiveFunction != nil && !isActiveFunction!()){
			self.tintInactive()
			return
		}
		self.contentTintColor = prevDefaultTint ?? defaultTint
	}
	
	func setMouseDownFunction(_ function: ((NSEvent) -> Void)?){
		self.mouseDownFunction = function
	}
	
	func setMouseDownFunction(_ function: ((NSEvent, Any) -> Void)?, with context: Any){
		self.mouseDownFunctionWContext = function
		self.clickContext = context
	}
	
	func tintInactive(){
		self.contentTintColor = NSColor(.sand8)
	}
	
	func tintActive(){
		self.contentTintColor = defaultTint
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		mouseDownFunction = nil
		isActiveFunction = nil
	}
}
