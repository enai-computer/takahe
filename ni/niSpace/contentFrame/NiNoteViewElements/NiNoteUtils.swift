//
//  NiTextFieldUtils.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

func getNewNoteItem(owner: ContentFrameController, parentView: NSView, frame: NSRect, text: String? = nil) -> NiNoteItem{
	let item = NiNoteItem(frame: frame, initText: text)	//owner: owner,
	item.owner = owner
	item.loadView()
	return item
}

func getNewStickyItem(owner: ContentFrameController, parentView: NSView, color: StickyColor, frame: NSRect, text: String? = nil) -> NiNoteItem{
	let item = NiNoteItem(frame: frame, initText: text, backgroundColor: color)
	item.owner = owner
	item.loadView()
	
	return item
}
