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
	
	//copied from here: https://stackoverflow.com/questions/2654580/how-to-resize-nstextview-according-to-its-content
	var heightConstraint: NSLayoutConstraint?
	var contentSize: CGSize {
		get {
			guard let layoutManager = layoutManager, let textContainer = textContainer else {
				return .zero
			}

			layoutManager.ensureLayout(for: textContainer)
			return layoutManager.usedRect(for: textContainer).size
		}
	}

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
	
	override func layout() {
		super.layout()
		frame.size.height = contentSize.height + 20.0
	}
}
