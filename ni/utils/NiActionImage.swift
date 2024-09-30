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
	private var rightMouseDownFunction: ((NSEvent) -> Void)?
	private var rightMouseDownFunctionWContext: ((NSEvent, Any) -> Void)?
	var mouseDownInActiveFunction: ((NSEvent) -> Void)?
	var isActiveFunction: (() -> Bool)?
	private var clickContext: Any?
	private var rightClickContext: Any?
	private let triggerOnDown: Bool
	private var mouseDownSince: Int64?
	
	@IBInspectable public var defaultTint: NSColor = .sand11
	
	private var prevDefaultTint: NSColor?
	
	init(image: NSImage, with size: NSSize? = nil, triggerOnDown: Bool = true){
		self.triggerOnDown = triggerOnDown
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
	
	convenience init?(namedImage: NSImage.Name, with size: NSSize? = nil, triggerOnDown: Bool = true){
		guard let img: NSImage = NSImage(named: namedImage) else {return nil}
		self.init(image: img, with: size, triggerOnDown: triggerOnDown)
	}
	
	required init?(coder: NSCoder) {
		triggerOnDown = true
		super.init(coder: coder)
		
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}
	
	override func mouseDown(with event: NSEvent) {
		guard triggerOnDown else{
			mouseDownSince = Date().currentTimeMillis()
			return
		}
		
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
	
	override func mouseUp(with event: NSEvent) {
		guard !triggerOnDown else{return}
		
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
		
		mouseDownSince = nil
	}
	
	override func rightMouseDown(with event: NSEvent) {
		//if is not active - don't change color
		if(isActiveFunction != nil && !isActiveFunction!()){
			return
		}
		if(clickContext != nil){
			rightMouseDownFunctionWContext?(event, rightClickContext as Any)
			return
		}
		rightMouseDownFunction?(event)
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
			return
		}
		self.contentTintColor = prevDefaultTint ?? defaultTint
	}
	
	func setMouseDownFunction(_ function: ((NSEvent) -> Void)?){
		self.mouseDownFunction = function
	}
	
	func setMouseDownFunction(_ function: ((NSEvent, Any) -> Void)?, with context: Any?){
		self.mouseDownFunctionWContext = function
		self.clickContext = context
	}

	func setRightMouseDownFunction(_ function: ((NSEvent) -> Void)?){
		self.rightMouseDownFunction = function
	}
	
	func setRightMouseDownFunction(_ function: ((NSEvent, Any) -> Void)?, with context: Any?){
		self.rightMouseDownFunctionWContext = function
		self.rightClickContext = context
	}
	
	func updateRightMouseDownContext(_ context: Any){
		self.rightClickContext = context
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
	
	func deinitSelf(){
		mouseDownFunction = nil
		mouseDownFunctionWContext = nil
		rightMouseDownFunction = nil
		rightMouseDownFunctionWContext = nil
		
		mouseDownInActiveFunction = nil
		isActiveFunction = nil
		clickContext = nil
		rightClickContext = nil
	}
}
