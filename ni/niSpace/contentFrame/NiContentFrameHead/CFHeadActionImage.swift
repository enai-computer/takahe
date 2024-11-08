//
//  CFHeadActionImage.swift
//  Enai
//
//  Created by Patrick Lukas on 7/11/24.
//

import Cocoa
import QuartzCore

@objc enum CFHeadButtonType: Int{
	case fwd = 0
	case back = 1
	case add = 2
	case expand = 3
	case minimize = 4
	case close = 5
	case maximize = 6
}

@objc protocol CFHeadActionImageDelegate: AnyObject {
	func isButtonActive(_ type: CFHeadButtonType) -> Bool
	func mouseUp(with event: NSEvent, for type: CFHeadButtonType)
}

@IBDesignable
class CFHeadActionImage: NSImageView{
	
	@IBInspectable public var defaultTint: NSColor = .sand11
	@IBInspectable var hoverTint: NSColor? = .birkin
	@IBInspectable public var buttonType: CFHeadButtonType = .fwd
	
	@IBOutlet weak var mouseDelegate: CFHeadActionImageDelegate!
	
	private var prevDefaultTint: NSColor?
	private var mouseDragged: Bool = false
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}

	override func prepareForInterfaceBuilder(){
		super.prepareForInterfaceBuilder()
		print("passed here")
	}
	
	override open func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func mouseDown(with event: NSEvent) {
		mouseDragged = false
		super.mouseDown(with: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		mouseDragged = true
		if(hoverTint != nil){
			self.contentTintColor = prevDefaultTint ?? defaultTint
		}
		super.mouseDragged(with: event)
	}
	
	override func mouseUp(with event: NSEvent){
		super.mouseUp(with: event)
		if(mouseDragged){return}
		guard mouseDelegate.isButtonActive(buttonType) else {return}
		mouseDelegate.mouseUp(with: event, for: buttonType)
	}
	
	override func mouseEntered(with event: NSEvent) {
		prevDefaultTint = self.contentTintColor
		
		//if is not active - don't change color
		if(!mouseDelegate.isButtonActive(buttonType)){
			return
		}
		if(hoverTint != nil){
			self.contentTintColor = hoverTint
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		//if is not active - don't change color
		if(!mouseDelegate.isButtonActive(buttonType)){
			return
		}
		if(hoverTint != nil){
			self.contentTintColor = prevDefaultTint ?? defaultTint
		}
	}
	
	func tintInactive(){
		self.contentTintColor = NSColor(.sand8)
		prevDefaultTint = NSColor(.sand8)
	}
	
	func tintActive(){
		self.contentTintColor = defaultTint
		prevDefaultTint = defaultTint
	}
}
