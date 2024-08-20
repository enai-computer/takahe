//
//  NiScrollView.swift
//  ni
//
//  Created by Patrick Lukas on 25/4/24.
//

import Cocoa

class NiScrollView: NSScrollView {
	//needed for some reason, otherwise scrollView will not behave the way we expect
	
	var allowScrolling: Bool = true
	
	override func scrollWheel(with event: NSEvent) {
		if(allowScrolling){
			super.scrollWheel(with: event)
		}
	}
	
	override func scrollPageUp(_ sender: Any?) {
		if(allowScrolling){
			super.scrollPageUp(sender)
		}
	}
	
	override func scrollPageDown(_ sender: Any?) {
		if(allowScrolling){
			super.scrollPageDown(sender)
		}
	}
}
