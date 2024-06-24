//
//  NiImgView.swift
//  ni
//
//  Created by Patrick Lukas on 29/5/24.
//

import Cocoa
import Carbon.HIToolbox

class NiImgView: NSImageView, CFContentItem{
	
	var viewIsActive: Bool = false
	var owner: ContentFrameController?
	override var acceptsFirstResponder: Bool {return true}
	
	func setActive() {
		window?.makeFirstResponder(self)
	}
	
	func setInactive() -> FollowOnAction {
		return .nothing
	}
	
	func spaceClosed() {}
	func spaceRemovedFromMemory() {}
	
	override func cancelOperation(_ sender: Any?) {
		return
	}
	
	override func mouseDown(with event: NSEvent) {
		if(event.clickCount == 2){
			guard let controller = nextResponder?.nextResponder as? ContentFrameController else{return}
			controller.openSourceWebsite()
			return
		}
		nextResponder?.mouseDown(with: event)
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete){
			if(!isEditable){
				owner?.triggerCloseProcess(with: event)
				return
			}
		}
		super.keyDown(with: event)
	}
	
	override func rightMouseDown(with event: NSEvent) {
		return
	}

}
