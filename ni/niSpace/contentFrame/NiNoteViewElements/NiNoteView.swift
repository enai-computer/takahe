//
//  NiNoteView.swift
//  ni
//
//  Created by Patrick Lukas on 3/6/24.
//

import Cocoa
import Carbon.HIToolbox

class NiNoteView: NSTextView{
	
	var myController: NiNoteItem?
	
	override var acceptsFirstResponder: Bool {return true}
	
	override func cancelOperation(_ sender: Any?) {
		_ = delegate?.textShouldEndEditing?(self)
		return
	}
	
	override func mouseDown(with event: NSEvent) {
		if(!isEditable && event.clickCount == 2){
			myController?.startEditing()
		}else if(!isEditable && event.clickCount == 1){
			nextResponder?.mouseDown(with: event)
			return
		}
		super.mouseDown(with: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		if(!isEditable){
			nextResponder?.mouseDragged(with: event)
			return
		}
		super.mouseDragged(with: event)
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete){
			if(!isEditable){
				myController?.owner?.triggerCloseProcess(with: event)
				return
			}
		}
		if(event.keyCode == kVK_Escape && isEditable){
			myController?.stopEditing()
			return
		}
		
		if(!isEditable){
			myController?.startEditing()
			moveToEndOfDocument(nil)
		}
		super.keyDown(with: event)
	}
}
