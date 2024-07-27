//
//  NSPanelUtils.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

extension NSPanel{
	
	static func rectForScreen(_ frameRect: NSRect, screen: NSScreen) -> NSRect {
		let frameOrigin = NSPoint(
			x: screen.frame.origin.x + frameRect.origin.x,
			y: screen.frame.origin.y + frameRect.origin.y)
		return NSRect(origin: frameOrigin, size: frameRect.size)
	}
	
	func setupBlurOnView(_ blurView: NSView, inputRadius: CGFloat, inputSaturation: CGFloat){
	   blurView.layer?.backgroundColor = NSColor.clear.cgColor
	   blurView.layer?.masksToBounds = true
	   blurView.layerUsesCoreImageFilters = true
	   blurView.layer?.needsDisplayOnBoundsChange = true

	   let satFilter = CIFilter(name: "CIColorControls")!
	   satFilter.setDefaults()
	   satFilter.setValue(NSNumber(value: inputSaturation), forKey: "inputSaturation")

	   let blurFilter = CIFilter(name: "CIGaussianBlur")!
	   blurFilter.setDefaults()
	   blurFilter.setValue(NSNumber(value: inputRadius), forKey: "inputRadius")

	   blurView.layer?.backgroundFilters = [satFilter, blurFilter]
   }
}
