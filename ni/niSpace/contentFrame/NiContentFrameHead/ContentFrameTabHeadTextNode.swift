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
	
	var parentController: ContentFrameTabHead?
	
	var defaultSize: CGSize?

	
	override func mouseDown(with event: NSEvent) {
		if(!self.isEditable && event.clickCount == 1){
			nextResponder?.mouseDown(with: event)
			return
		}
		
		if(!self.isEditable && event.clickCount == 2){
			parentController?.startEditMode()
			return
		}
		nextResponder?.mouseDown(with: event)
	}
	
	override func keyDown(with event: NSEvent) {
		if(self.isEditable && event.keyCode == kVK_Escape){
			endEditing()
		}else{
			nextResponder?.keyDown(with: event)
		}
	}
	
	override func cancelOperation(_ sender: Any?) {
		endEditing()
	}
	
	override func textDidEndEditing(_ notification: Notification) {
		do{
			let url = try urlOrSearchUrl(from: self.stringValue)
			self.parentController?.loadWebsite(url: url)
		}catch{
			print("Failed to load website, due to " + error.localizedDescription)
		}
		endEditing()
	}

	func enableEditing(urlStr: String){
		self.isEditable = true
		self.isSelectable = true
		self.stringValue = urlStr
		self.textColor = NSColor(.textLight)
		self.backgroundColor = NSColor(.textBackgroundDark)
		self.drawsBackground = true
		self.currentEditor()?.moveToEndOfLine(nil)
	}
	
	func disableEditing(title: String){
		self.isEditable = false
		self.isSelectable = false
		self.stringValue = title
		self.textColor = NSColor(.textDark)
		self.backgroundColor = NSColor(.transparent)
		self.drawsBackground = false
	}
	
	private func endEditing(){
		parentController?.endEditMode()
	}
}
