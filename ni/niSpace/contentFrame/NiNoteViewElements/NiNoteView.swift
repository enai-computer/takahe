//
//  NiTextFieldView.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

class NiNoteView: NSTextView, CFElement {
	
	func setActive() {
		self.isEditable = true
		self.isSelectable = true
	}
	
	func setInactive() {
		self.isEditable = false
		self.isSelectable = false
	}
}
