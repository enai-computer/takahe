//
//  NiBlur.swift
//  ni
//
//  Created by Patrick Lukas on 5/7/24.
//

import Cocoa

func setupBlurLayer(_ blurView: NSView, inputRadius: CGFloat, inputSaturation: CGFloat){
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
