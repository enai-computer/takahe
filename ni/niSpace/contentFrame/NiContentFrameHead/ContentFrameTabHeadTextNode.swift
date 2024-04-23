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
	
	var parentController: ContentFrameTabHead?{
		set { delegate = newValue }
		get { (delegate as! ContentFrameTabHead) }
	}
	
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
	
	//needed to handle ESC
	override func cancelOperation(_ sender: Any?) {
		parentController?.endEditMode()
	}
	

	func enableEditing(urlStr: String){
		self.stringValue = urlStr
		
		guard !self.isEditable else { return }
		
		self.isEditable = true
		self.isSelectable = true
		self.textColor = NSColor(.textLight)
		self.backgroundColor = NSColor(.textBackgroundDark)
		self.drawsBackground = true
		
		//starts editing
		self.selectText(nil)
		self.currentEditor()?.moveToEndOfLine(nil)
	}
	
	func disableEditing(title: String){
		self.stringValue = title
		
		guard self.isEditable else { return }
		
		self.isEditable = false
		self.isSelectable = false
		self.textColor = NSColor(.textDark)
		self.backgroundColor = NSColor(.transparent)
		self.drawsBackground = false
	}

}
