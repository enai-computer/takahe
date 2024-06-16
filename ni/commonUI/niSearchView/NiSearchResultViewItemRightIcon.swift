//
//  NiSearchResultViewItemRightIcon.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class NiSearchResultViewItemRightIcon: NSView {
	
	private var shortcut: NSTextField? = nil
	private var isSelected: Bool = true
	
	func configureElement(_ position: Int){
		//needed as parent ViewItem gets recylced
		shortcut?.removeFromSuperview()
		isSelected = false
		
		if(0 < position && position < 6){
			shortcut = NSTextField(labelWithString: getText(position))
			shortcut?.frame.size = self.frame.size
			shortcut?.textColor = NSColor.sand9
			shortcut?.font = NSFont(name: "Sohne-Buch", size: 16.0)
			self.addSubview(shortcut!)
		}
	}
	
	func select(){
		isSelected = true
		draw(frame)
	}
	
	func deselect(){
		isSelected = false
		draw(frame)
	}
	
	override func draw(_ dirtyRect: NSRect) {
		if(isSelected){
			NSImage.returnIcon.draw(in: NSRect(x: 12.0, y: 0.5, width: 18.0, height: 22.0))
		}else{
			super.draw(dirtyRect)
		}
	}
	
	private func getText(_ position: Int) -> String{
		return "⌘ \(position)"
	}
}
