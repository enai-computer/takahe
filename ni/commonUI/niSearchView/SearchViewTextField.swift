//
//  SearchViewTextField.swift
//  ni
//
//  Created by Patrick Lukas on 16/6/24.
//

import Cocoa

//Testing so key commands do not pass through to the next window.
//TODO: remove if unneeded
class SearchViewTextField: NSTextField{
	
	override func moveUp(_ sender: Any?) {
		return
	}
	
//	override func sendAction(_ action: Selector?, to target: Any?) -> Bool {
//		super.sendAction(action, to: target)
//	}
	
	override func keyUp(with event: NSEvent){
		super.keyUp(with: event)
	}
	
	override func cancelOperation(_ sender: Any?) {
		var nxtResp = nextResponder
		while nxtResp != nil{
			if(nxtResp is NiSearchController){
				nxtResp?.cancelOperation(sender)
				return
			}
			nxtResp = nxtResp?.nextResponder
		}
	}
}
