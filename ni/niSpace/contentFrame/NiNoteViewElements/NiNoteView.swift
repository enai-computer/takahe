//
//  NiTextFieldView.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa
import Carbon.HIToolbox

class NiNoteView: NSTextView, CFContentItem {
	
	private var overlay: NSView?
	var owner: ContentFrameController?
	var parentView: CFFramelessView? {return superview as? CFFramelessView }
	var viewIsActive: Bool {return isEditable}
	
	func setActive() {
		overlay?.removeFromSuperview()
		overlay = nil
		self.isSelectable = true
		
		setStyling()
		window?.makeFirstResponder(self)
	}
	
	func setInactive() -> FollowOnAction{
		setStyling()
		
		self.isEditable = false
		self.isSelectable = false
		let content = getText()
		if(content == nil || content!.isEmpty){
			return .removeSelf
		}
		
		overlay = cfOverlay(frame: self.frame, nxtResponder: self.nextResponder)
		self.addSubview(overlay!)
		window?.makeFirstResponder(overlay)
		
		return .nothing
	}
	
	func startEditing(){
		self.isEditable = true
		parentView?.removeBorder()
	}
	
	func stopEditing(){
		self.isEditable = false
		parentView?.setBorder()
	}
	
	private func setStyling(){
		self.wantsLayer = true
		self.backgroundColor = NSColor.sandLight3
		self.layer?.cornerRadius = 5
		self.layer?.cornerCurve = .continuous
	}
	
	override func cancelOperation(_ sender: Any?) {
		_ = delegate?.textShouldEndEditing?(self)
		return
	}
	
	override func mouseDown(with event: NSEvent) {
		if(!isEditable && event.clickCount == 2){
			startEditing()
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
				owner?.triggerCloseProcess(with: event)
				return
			}
		}
		if(event.keyCode == kVK_Escape && isEditable){
			stopEditing()
			return
		}
		
		if(!isEditable){
			startEditing()
		}
		super.keyDown(with: event)
	}
	
	func getText() -> String? {
		return self.textStorage?.string.trimmingCharacters(in: .whitespaces)
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
