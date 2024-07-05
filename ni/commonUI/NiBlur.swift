//
//  NiBlur.swift
//  ni
//
//  Created by Patrick Lukas on 5/7/24.
//

import Cocoa

func setupBlurLayerView(_ blurView: NSView, inputRadius: CGFloat, inputSaturation: CGFloat){
	blurView.layer?.backgroundColor = NSColor.clear.cgColor
	blurView.layer?.masksToBounds = true
	blurView.layerUsesCoreImageFilters = true
	blurView.layer?.needsDisplayOnBoundsChange = true

	blurView.layer?.backgroundFilters = getBlurFilter(inputRadius: inputRadius, inputSaturation: inputSaturation)
}

func getBlurFilter(inputRadius: CGFloat, inputSaturation: CGFloat) -> [CIFilter]{
	let satFilter = CIFilter(name: "CIColorControls")!
	satFilter.setDefaults()
	satFilter.setValue(NSNumber(value: inputSaturation), forKey: "inputSaturation")

	let blurFilter = CIFilter(name: "CIGaussianBlur")!
	blurFilter.setDefaults()
	blurFilter.setValue(NSNumber(value: inputRadius), forKey: "inputRadius")
	
	return [satFilter, blurFilter]
}
