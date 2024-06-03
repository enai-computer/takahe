//
//  NiImgViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 29/5/24.
//

import Cocoa

func getNewImgView(owner: ContentFrameController, parentView: NSView, img: NSImage) -> NiImgView{
	let view = NiImgView(image: img)
	view.owner = owner
	view.autoresizesSubviews = true
	view.imageScaling = .scaleProportionallyUpOrDown
	view.animates = false
	return view
}
