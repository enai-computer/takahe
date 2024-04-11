//
//  ContentFrameTabHeadView.swift
//  ni
//
//  Created by Patrick Lukas on 8/4/24.
//

import Foundation
import Cocoa

class ContentFrameTabHeadView: NSView{
	
	var parentControler: ContentFrameTabHead?
	
	override func mouseDown(with event: NSEvent) {
		parentControler?.selectSelf(mouseDownEvent: event)
	}
}
