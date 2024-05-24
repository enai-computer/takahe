//
//  SpaceTopbar.swift
//  ni
//
//  Created by Patrick Lukas on 22/5/24.
//

import Cocoa

class SpaceTopbar: NSBox{
	
	//needed as otherwise contentFrames will catch the mouseDown events
	override func mouseDown(with event: NSEvent) {
		nextResponder?.mouseDown(with: event)
	}
}
