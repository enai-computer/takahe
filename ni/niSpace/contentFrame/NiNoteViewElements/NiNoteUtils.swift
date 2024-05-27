//
//  NiTextFieldUtils.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

func getNewNoteView(parentView: NSView, frame: NSRect) -> NiNoteView{
	let view = NiNoteView(frame: frame)
	
	view.backgroundColor = NSColor.sandLight2
	view.insertionPointColor = NSColor.birkin
	view.importsGraphics = false
	view.allowsImageEditing = false
	view.displaysLinkToolTips = false
	view.usesFindBar = false
	view.usesFindPanel = false
	view.usesFontPanel = false
	view.isRichText = false
	view.isVerticallyResizable = false
	view.isHorizontallyResizable = false
	view.font = NSFont(name: "Sohne-Buch", size: 16.0)
	view.textColor = NSColor.sandDark7
	
	return view
}
