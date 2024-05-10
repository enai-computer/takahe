//
//  NiActionImage.swift
//  ni
//
//  Created by Patrick Lukas on 29/4/24.
//

import Cocoa


class NiActionImage: NSImageView{
	
	var mouseDownFunction: ((NSEvent) -> Void)?
	var isActiveFunction: (() -> Bool)?
	private var prevColor: NSColor? = nil

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
	}
	
	override func mouseDown(with event: NSEvent) {
		if (mouseDownFunction != nil){
			mouseDownFunction!(event)
		}
	}
	
	override func mouseEntered(with event: NSEvent) {
		//if is not active - don't change color
		if(isActiveFunction != nil){
			if(!isActiveFunction!()){
				return
			}
		}
		prevColor = self.contentTintColor
		self.contentTintColor = NSColor(.intAerospaceOrange)
	}
	
	override func mouseExited(with event: NSEvent) {
		//if is not active - don't change color
		if(isActiveFunction != nil){
			if(!isActiveFunction!()){
				return
			}
		}
		if(prevColor != nil){
			self.contentTintColor = prevColor!
		}else{
			self.contentTintColor = NSColor(.sandLight11)
		}
	}
}
