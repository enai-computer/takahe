//
//  NiTextFieldView.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

class NiNoteView: NSTextView, CFContentItem {
	
	func setActive() {
		self.isEditable = true
		self.isSelectable = true
	}
	
	func setInactive() {
		self.isEditable = false
		self.isSelectable = false
	}
	
	override func cancelOperation(_ sender: Any?) {
		return
	}
	
	func getText() -> String? {
		return self.textStorage?.string
	}
	
	func getTitle() -> String? {
		let note = getText()
		if(note == nil || note!.isEmpty){
			return nil
		}
		let endOfFirstLine = note!.firstIndex(of: "\n")
		if(endOfFirstLine == nil){
			return nil
		}
		
		let firstLine = note![..<endOfFirstLine!]
		return String(firstLine)
	}
}
