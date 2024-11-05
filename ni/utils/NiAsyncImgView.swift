//
//  NiAsyncImgView.swift
//  ni
//
//  Created by Patrick Lukas on 16/9/24.
//

import Cocoa

protocol NiMouseDownHandler{
	func niLeftMouseDown(trigger: NSView, context: Any?)
	func isFrameActive() -> Bool
}

class NiAsyncImgView: NSView{
	
	private weak var mouseHandlerStorage: NSObject?
	private var mouseHandler: NiMouseDownHandler? {return mouseHandlerStorage as? NiMouseDownHandler}
	private var mouseDownContext: Any?
	private var image: NSImage?
	
	init(mouseHandler: NiMouseDownHandler?,
		 mouseDownContext: Any? = nil,
		 frame: NSRect? = nil
	){
		if let mhObj = mouseHandler as? NSObject{
			self.mouseHandlerStorage = mhObj
		}
		self.mouseDownContext = mouseDownContext
		
		if(frame == nil){
			super.init(frame: NSRect(x: 0, y: 0, width: 24, height: 24))
		}else{
			super.init(frame: frame!)
		}
		let hoverEffect = NSTrackingArea.init(rect: self.bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffect)
		self.alphaValue = 0.7
	}
	
	required init?(coder: NSCoder) {
		fatalError("Not implemented")
	}
	
	func setImage(_ img: NSImage){
		self.image = img
		self.needsDisplay = true
	}
	
	func loadFavIcon(from urlStr: String?) {
		guard let urlStr else {return}

		Task.detached { [weak self] in
			guard let image = await FaviconProvider.instance.fetchIcon(urlStr) ?? NSImage(named: NSImage.Name("enaiIcon")) else { return }
			await self?.setImage(image)
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		guard let image = self.image else {
			return
		}
		image.draw(in: bounds)
	}
	
	override func mouseDown(with event: NSEvent) {
		guard let mouseHandler else {
			// Let clicks fall-through if no click handler is set.
			super.mouseDown(with: event)
			return
		}
		guard self.image != nil else {return}
		mouseHandler.niLeftMouseDown(trigger: self, context: mouseDownContext)
	}
	
	override func mouseEntered(with event: NSEvent) {
		if(mouseHandler?.isFrameActive() == false){
			return
		}
		self.alphaValue = 1.0
	}
	
	override func mouseExited(with event: NSEvent) {
		self.alphaValue = 0.7
	}
}
