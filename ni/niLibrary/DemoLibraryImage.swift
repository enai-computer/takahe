//
//  DemoLibraryImage.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class DemoLibraryImage: NSImageView{
	
	@IBInspectable public var disappear: Bool = true
	
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
		layer?.borderWidth = 1.0
	}
	
	override func mouseExited(with event: NSEvent) {
		layer?.borderWidth = 0.0
	}
}
