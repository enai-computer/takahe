//
//  DemoLibraryImage.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class DemoLibraryImage: NSImageView{
	
	@IBInspectable public var disappear: Bool = true
	
	private var hoverImg: NSImage?
	private var blurredImg: NSImage?
	private var active = false
	var mouseDownFunction: ((NSEvent) -> Void)?
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		self.wantsLayer = true
		layer?.cornerRadius = 15.0
		layer?.cornerCurve = .continuous
		
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}
	
	func tryHide(){
		if(disappear){
			self.isHidden = true
		}
	}
	
	func unhide(){
		isHidden = false
	}
	
	override func mouseEntered(with event: NSEvent) {
		layer?.borderColor = NSColor.birkin.cgColor
		layer?.borderWidth = 2.0
		
		if(hoverImg != nil && !active){
			blurredImg = self.image
//			transition(to: hoverImg, duration: 0.3)
			self.image = hoverImg
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		layer?.borderWidth = 0.0
		
		if(blurredImg != nil && !active){
//			transition(to: blurredImg, duration: 0.3)
			self.image = blurredImg
		}
	}
	
	override func mouseDown(with event: NSEvent) {
		mouseDownFunction?(event)
		if(mouseDownFunction != nil){
			active = !active
		}
	}
	
	func setHoverImg(_ name: String){
		hoverImg = NSImage(named: name)
		hoverImg?.size = self.frame.size
	}

	func transition(to image: NSImage?, duration: TimeInterval = 0.5) {
		// Create a temporary image view to perform the transition
		let tempImageView = NSImageView(frame: bounds)
		tempImageView.image = image
		tempImageView.animates = false
		tempImageView.imageScaling = .scaleProportionallyUpOrDown
		
		// Add the temporary image view in front of the current one
		addSubview(tempImageView, positioned: .above, relativeTo: self)
		
		// Animate the fade transition using the animator proxy
		NSAnimationContext.runAnimationGroup({ (context) in
			context.duration = duration
			tempImageView.animator().alphaValue = 1.0
		}) {
			// Remove the temporary image view and set the final image
			tempImageView.removeFromSuperview()
			self.image = image
		}
	}

}
