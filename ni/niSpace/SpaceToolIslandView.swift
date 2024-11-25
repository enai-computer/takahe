//
//  SpaceToolIslandView.swift
//  Enai
//
//  Created by Patrick Lukas on 25/11/24.
//

import Cocoa

class SpaceToolIslandView: NSView{
	
	override func awakeFromNib(){
		super.awakeFromNib()
		wantsLayer = true
		
		layer?.cornerCurve = .continuous
		layer?.cornerRadius = 15.0
		
		layer?.backgroundColor = NSColor.sand3.cgColor
		
		layer?.shadowColor = NSColor.sand9.cgColor
		layer?.shadowOffset = CGSize(width: 0.0, height: -1.0)
		layer?.shadowOpacity = 1.0
		layer?.shadowRadius = 2.0
		layer?.masksToBounds = false
		
		let innerShadowLayer = CALayer()
		innerShadowLayer.cornerRadius = 15.0
		innerShadowLayer.masksToBounds = true
		innerShadowLayer.shadowColor = NSColor.sand1.cgColor
		innerShadowLayer.shadowOffset = NSSize(width: 0.0, height: -1.0)
		innerShadowLayer.shadowOpacity = 1.0
		innerShadowLayer.shadowRadius = 1.0
		innerShadowLayer.frame = bounds.insetBy(dx: 0.2, dy: 0.5)
		
		layer?.addSublayer(innerShadowLayer)
	}
	
	override func mouseDown(with even: NSEvent){
		
	}
}
