//
//  NiMenuItemView.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

class NiMenuItemView: NSView{
	
	@IBOutlet var title: NSTextField!
	private var isEnabledStorage = true
	var isEnabled: Bool{
		set {
			guard isEnabledStorage != newValue else {return}
			isEnabledStorage = newValue
			if(newValue){
				title.textColor = NSColor.sand12
			}else{
				title.textColor = NSColor.sand8
			}
		}
		get{
			isEnabledStorage
		}
	}
	var mouseDownFunction: ((NSEvent) -> Void)?
	
	override func updateTrackingAreas() {
		let hoverEffect = NSTrackingArea.init(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
		addTrackingArea(hoverEffect)
	}
	
	override func mouseEntered(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		wantsLayer = true
		layer?.backgroundColor = NSColor.sand4.cgColor
		layer?.cornerRadius = 8.0
		layer?.cornerCurve = .continuous
	}
	
	override func mouseExited(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		layer?.backgroundColor = NSColor.sand2.cgColor
	}
	
	override func mouseDown(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		mouseDownFunction?(event)
		window?.orderOut(nil)
		window?.close()
	}
}
