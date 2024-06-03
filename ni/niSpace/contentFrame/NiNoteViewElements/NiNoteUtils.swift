//
//  NiTextFieldUtils.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

func getNewNoteView(owner: ContentFrameController, parentView: NSView, frame: NSRect) -> NiNoteItem{
	let view = NiNoteItem()//(frame: frame)	//owner: owner,
	view.owner = owner
//	
//	view.textContainerInset = NSSize(width: 6.0, height: 6.0)
//	view.backgroundColor = NSColor.sandLight3
//	view.insertionPointColor = NSColor.birkin
//	view.importsGraphics = false
//	view.allowsImageEditing = false
//	view.displaysLinkToolTips = false
//	view.usesFindBar = false
//	view.usesFindPanel = false
//	view.usesFontPanel = false
//	view.isRichText = false
//	view.isVerticallyResizable = false
//	view.isHorizontallyResizable = false
//	view.isEditable = false
//	
//	view.font = NSFont(name: "Sohne-Buch", size: 16.0)
//	view.textColor = NSColor.sandDark7
//	
//	
	return view
}
