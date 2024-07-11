//
//  SpaceTopbar.swift
//  ni
//
//  Created by Patrick Lukas on 22/5/24.
//

import Cocoa

class SpaceTopbar: NSBox{
	
	private var contentBlurView: NSView?
	private var visualEffectsView: NSVisualEffectView?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		contentView?.wantsLayer = true
		contentView?.layer?.cornerRadius = 15.0
		contentView?.layer?.cornerCurve = .continuous
		contentView?.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		contentView?.layer?.masksToBounds = true
		contentView?.layer?.backgroundColor = NSColor(.sand1T10).cgColor
		
		contentBlurView = NSView(frame: self.frame)
		contentBlurView?.wantsLayer = true
		setupBlurLayerView(contentBlurView!, inputRadius: 10.0, inputSaturation: 0.0)
		contentBlurView?.layer?.cornerRadius = 15.0
		superview!.addSubview(contentBlurView!, positioned: .below, relativeTo: self)
	}
	
	override func updateTrackingAreas() {
		super.updateTrackingAreas()
	}
	
	override func resize(withOldSuperviewSize oldSize: NSSize) {
		super.resize(withOldSuperviewSize: oldSize)
		contentBlurView?.frame = frame
		visualEffectsView?.frame = frame
	}
	
	override func mouseEntered(with event: NSEvent) {
		contentView?.layer?.backgroundColor = NSColor.sand1.cgColor
	}
	
	override func mouseExited(with event: NSEvent) {
		contentView?.layer?.backgroundColor = NSColor.sand1T10.cgColor
	}
	
	//needed as otherwise contentFrames will catch the mouseDown events
	override func mouseDown(with event: NSEvent) {
		nextResponder?.mouseDown(with: event)
	}
}
