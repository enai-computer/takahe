//
//  ContentFrameTabHeadView.swift
//  ni
//
//  Created by Patrick Lukas on 5/4/24.
//

import Foundation
import Cocoa
import Carbon.HIToolbox

class ContentFrameTabHeadTextNode: NSTextField{
	
	var urlStr: String = ""
	var parentView: NSView?
	var parentController: ContentFrameTabHead?
	
	var defaultSize: CGSize?

	
	override func mouseDown(with event: NSEvent) {
		if(!self.isEditable && event.clickCount == 1){
			nextResponder?.mouseDown(with: event)
			return
		}
		
		if(event.clickCount == 2){
			enableEditing()
		}
	}
	
	override func keyDown(with event: NSEvent) {
		if(self.isEditable && event.keyCode == kVK_Escape){
			disableEditing()
		}
	}
	
	override func cancelOperation(_ sender: Any?) {
		disableEditing()
	}
	
	override func textDidEndEditing(_ notification: Notification) {
		do{
			try self.parentController?.loadWebsite(newURL: self.stringValue)
			disableEditing()
		}catch{
			print("Failed to load website, due to " + error.localizedDescription)
		}
	}

	private func enableEditing(){
		self.isEditable = true
		self.isSelectable = true
		self.stringValue = urlStr
		
		defaultSize = parentView?.frame.size
		var nSize = parentView?.frame.size
		if(nSize != nil){
			nSize?.width = CGFloat(urlStr.count) * 8.0 + 30
			parentView!.frame.size = nSize!
//			parentController?.redraw()
		}
		
		self.textColor = NSColor(.textLight)
		self.backgroundColor = NSColor(.textBackgroundDark)
		self.drawsBackground = true
		
		self.currentEditor()?.moveToEndOfLine(nil)
	}
	
	private func disableEditing(){
		self.isEditable = false
		self.isSelectable = false
		
		self.textColor = NSColor(.textDark)
		self.backgroundColor = NSColor(.transparent)
		self.drawsBackground = false
		
		if(defaultSize != nil){
			parentView?.frame.size = defaultSize!
		}
		
	}
}
