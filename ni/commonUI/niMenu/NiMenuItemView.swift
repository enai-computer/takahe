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
	
	private var birkinHighlight: NSView? = nil
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
		layer?.backgroundColor = NSColor.sand1.cgColor
		layer?.cornerRadius = 2.0
		layer?.cornerCurve = .continuous
		birkinHighlight = getBirkinView()
		addSubview(birkinHighlight!)
		title.textColor = NSColor.sand12
	}
	
	override func mouseExited(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		layer?.backgroundColor = NSColor.sand3.cgColor
		birkinHighlight?.removeFromSuperview()
		birkinHighlight = nil
		title.textColor = NSColor.sand115
	}
	
	override func mouseDown(with event: NSEvent) {
		if(!isEnabled){
			return
		}
		mouseDownFunction?(event)
		window?.orderOut(nil)
		window?.close()
	}
	
	private func getBirkinView() -> NSView{
		let birkinFrame = NSRect(origin: NSPoint(x: 0.0, y: 0.0), size: CGSize(width: 2, height: frame.height))
		let birkinRect = NSView(frame: birkinFrame)
		birkinRect.wantsLayer = true
		birkinRect.layer?.backgroundColor = NSColor.birkin.cgColor
		return birkinRect
	}
}
