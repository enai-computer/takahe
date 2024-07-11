//
//  SpaceTopbar.swift
//  ni
//
//  Created by Patrick Lukas on 22/5/24.
//

import Cocoa

class SpaceTopbar: NSView{
	
	override func awakeFromNib() {
		super.awakeFromNib()
		wantsLayer = true
		
		layer?.shadowColor = NSColor.sand9.cgColor
		layer?.shadowRadius = 2.0
		layer?.shadowOffset = CGSize(width: 0.0, height: 0.0)
		layer?.shadowOpacity = 1.0
		
		layer?.cornerRadius = 10.0
		layer?.cornerCurve = .continuous
		layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		layer?.masksToBounds = true
		layer?.backgroundColor = NSColor(.sand1T10).cgColor
	}
	
	override func updateTrackingAreas() {
		super.updateTrackingAreas()
	}

	//needed as otherwise contentFrames will catch the mouseDown events
	override func mouseDown(with event: NSEvent) {
		nextResponder?.mouseDown(with: event)
	}
}
