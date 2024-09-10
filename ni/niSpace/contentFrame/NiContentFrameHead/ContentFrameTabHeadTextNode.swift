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
	
	weak var parentController: ContentFrameTabHead?{
		set { delegate = newValue }
		get { (delegate as! ContentFrameTabHead) }
	}
	
	var defaultSize: CGSize?
	
	//needed to handle ESC
	override func cancelOperation(_ sender: Any?) {
		parentController?.endEditMode()
	}
	

	func enableEditing(urlStr: String){
		self.stringValue = urlStr
		
		guard !self.isEditable else { return }
		
		self.isEditable = true
		self.isSelectable = true
		self.backgroundColor = NSColor(.transparent)
		self.drawsBackground = true
		
		//starts editing
		setBlinkingCursor()
	}
	
	func setBlinkingCursor(){
		guard self.isEditable else { return }
		//needs to be first responder & have a window
		//--> currentEditor does not return nil and we can get a blinking cursor
		self.selectText(nil)
		self.currentEditor()?.selectAll(nil)
	}
	
	func disableEditing(title: String){
		self.stringValue = title
		
		guard self.isEditable else { return }
		
		self.isEditable = false
		self.isSelectable = false
		self.backgroundColor = NSColor(.transparent)
		self.drawsBackground = false
	}

}
