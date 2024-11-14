//
//  NiMarkDownUtils.swift
//  Enai
//
//  Created by Patrick Lukas on 13/11/24.
//

import Cocoa

func getNewMarkDownItem(owner: ContentFrameController, parentView: NSView, frame: NSRect, text: String? = nil) -> NiMarkDownItem{
	let item = NiMarkDownItem(frame: frame, initText: text)	//owner: owner,
	item.owner = owner
	item.loadView()
	return item
}
