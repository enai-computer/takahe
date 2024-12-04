//
//  CallToActionImageView.swift
//  Enai
//
//  Created by Patrick Lukas on 4/12/24.
//

import Cocoa
import Carbon.HIToolbox

class CallToActionImageView: NSImageView{

	private var mouseDownFunction: ((NSEvent) -> Void)?
	
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
	}
	
	convenience init?(namedImage: NSImage.Name, with size: NSSize? = nil){
		guard let img: NSImage = NSImage(named: namedImage) else {return nil}
		self.init(image: img, with: size)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func mouseDown(with event: NSEvent) {
		mouseDownFunction?(event)
	}
	
	func setMouseDownFunction(_ function: ((NSEvent) -> Void)?){
		self.mouseDownFunction = function
	}
	
	override func resignFirstResponder() -> Bool {
		mouseDownFunction = nil
		removeFromSuperview()
		return true
	}
	
	override func keyDown(with event: NSEvent){
		if(event.keyCode == kVK_ANSI_KeypadEnter || event.keyCode == kVK_Return){
			mouseDownFunction?(event)
		}
		mouseDownFunction = nil
		removeFromSuperview()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		mouseDownFunction = nil
	}
	
	deinit{
		mouseDownFunction = nil
	}
}
