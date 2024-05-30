//
//  NiImgViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 29/5/24.
//

import Cocoa

func getNewImgView(owner: ContentFrameController, parentView: NSView, img: NSImage) -> NiImgView{
	let view = NiImgView(image: img)
	view.autoresizesSubviews = true
	
	return view
}
