//
//  NiImgView.swift
//  ni
//
//  Created by Patrick Lukas on 29/5/24.
//

import Cocoa

class NiImgView: NSImageView, CFContentItem{
	
	var viewIsActive: Bool = false
	
	func setActive() {}
	
	func setInactive() -> FollowOnAction {
		return .nothing
	}
	
	override func cancelOperation(_ sender: Any?) {
		return
	}
	
}
