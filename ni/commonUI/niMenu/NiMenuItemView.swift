//
//  NiMenuItemView.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

class NiMenuItemView: NSView{
	
	@IBOutlet var title: NSTextField!
	@IBOutlet var keyboardShortcut: NSTextField!
	
	private var isEnabledStorage = true
	var isEnabled: Bool{
		set {
			guard isEnabledStorage != newValue else {return}
			isEnabledStorage = newValue
			if(newValue){
				title.textColor = NSColor.sand12
			}else{
				title.textColor = NSColor.sand8
				keyboardShortcut.isHidden = true
			}
		}
		get{
			isEnabledStorage
		}
	}
	var mouseDownFunction: ((NSEvent) -> Void)?
	
	func setKeyboardshortcut(_ shortcut: String){
		guard isEnabled else {return}
		
		keyboardShortcut.stringValue = shortcut
		keyboardShortcut.isHidden = false
	}
	
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
