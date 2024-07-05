//
//  SpaceTopbar.swift
//  ni
//
//  Created by Patrick Lukas on 22/5/24.
//

import Cocoa

class SpaceTopbar: NSBox{
	
	private var hoverEffect: NSTrackingArea?
	override var allowsVibrancy: Bool {return true}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		contentView?.wantsLayer = true
		contentView?.layer?.cornerRadius = 15.0
		contentView?.layer?.cornerCurve = .continuous
		contentView?.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		contentView?.layer?.masksToBounds = true
		contentView?.layer?.backgroundColor = NSColor(.sand1T10).cgColor
//		contentView?.layer?.backgroundFilters = getBlurFilter(inputRadius: 15.0, inputSaturation: 1.0)
//		
//		hoverEffect = NSTrackingArea(rect: bounds,
//									 options: [.mouseEnteredAndExited, .activeInActiveApp],
//									 owner: self,
//									 userInfo: nil)
//		addTrackingArea(hoverEffect!)
	}
	
//	override func updateTrackingAreas() {
//		hoverEffect = NSTrackingArea(rect: bounds,
//									 options: [.activeInActiveApp, .mouseEnteredAndExited],
//									 owner: self,
//									 userInfo: nil)
//		addTrackingArea(hoverEffect!)
//	}
//	
//	override func mouseEntered(with event: NSEvent) {
//		contentView?.layer?.backgroundColor = NSColor.sand1.cgColor
//	}
	
	override func mouseExited(with event: NSEvent) {
		contentView?.layer?.backgroundColor = NSColor.sand1T10.cgColor
	}
	
	//needed as otherwise contentFrames will catch the mouseDown events
	override func mouseDown(with event: NSEvent) {
		nextResponder?.mouseDown(with: event)
	}
}
