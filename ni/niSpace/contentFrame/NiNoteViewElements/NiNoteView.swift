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
	private let owner: ContentFrameController
	
	init(owner: ContentFrameController, frame: NSRect){
		self.owner = owner
		super.init(frame: frame, textContainer: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setActive() {
		overlay?.removeFromSuperview()
		overlay = nil
		self.isEditable = true
		self.isSelectable = true
	}
	
	func setInactive() -> FollowOnAction{
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
	
	override func cancelOperation(_ sender: Any?) {
		delegate?.textShouldEndEditing?(self)
		return
	}
	
	override func mouseDown(with event: NSEvent) {
		if(!isEditable){
			isEditable = true
		}
		super.mouseDown(with: event)
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete){
			if(!isEditable){
				owner.triggerCloseProcess(with: event)
			}
		}
		if(event.keyCode == kVK_Escape){
			self.isEditable = false
			return
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
