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
	
	override func mouseEntered(with event: NSEvent) {
		layer?.borderColor = NSColor.birkin.cgColor
		layer?.borderWidth = 2.0
		
		if(hoverImg != nil){
			blurredImg = self.image
			self.image = hoverImg
		}
	}
	
	override func mouseExited(with event: NSEvent) {
		layer?.borderWidth = 0.0
		
		if(blurredImg != nil && !active){
			self.image = blurredImg
		}
	}
	
	override func mouseDown(with event: NSEvent) {
		mouseDownFunction?(event)
		if(mouseDownFunction != nil){
			active = true
		}
	}
	
	func setHoverImg(_ name: String){
		hoverImg = NSImage(named: name)
		hoverImg?.size = self.frame.size
	}
}
