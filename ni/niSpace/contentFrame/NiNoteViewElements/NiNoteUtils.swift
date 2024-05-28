//
//  NiTextFieldUtils.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

func getNewNoteView(owner: ContentFrameController, parentView: NSView, frame: NSRect) -> NiNoteView{
	let view = NiNoteView(owner: owner, frame: frame)
	
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
//	view.translatesAutoresizingMaskIntoConstraints = false
	
	view.font = NSFont(name: "Sohne-Buch", size: 16.0)
	view.textColor = NSColor.sandDark7
	
//	view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
//	view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
//	view.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
//	view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
	
	return view
}
