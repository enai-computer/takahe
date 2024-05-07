//
//  CFMinimizedStackItem.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//

import Cocoa

class CFMinimizedStackItem: NSView{
	
	@IBOutlet var tabIcon: NSImageView!
	@IBOutlet var tabTitle: NSTextField!
	private(set) var tabPosition: Int = -1
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		self.wantsLayer = true
		layer?.backgroundColor = NSColor(.sandLight3).cgColor
		layer?.borderWidth = 4
		layer?.borderColor = NSColor(.sandLight4).cgColor
		
		let hoverEffectTrackingArea = NSTrackingArea(rect: self.frame, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: nil)
		self.addTrackingArea(hoverEffectTrackingArea)
	}
	
	func setItemData(position: Int, title: String, icon: NSImage?){
		tabPosition = position
		tabTitle.stringValue = title
		if(icon != nil){
			tabIcon.image = icon
		}
	}
	
	override func mouseEntered(with event: NSEvent) {
		layer?.backgroundColor = NSColor(.sandLight1).cgColor
		tabTitle.textColor = NSColor(.sandLight12)
	}
	
	override func mouseExited(with event: NSEvent) {
		layer?.backgroundColor = NSColor(.sandLight3).cgColor
		tabTitle.textColor = NSColor(.sandLight11)
	}
	
}
