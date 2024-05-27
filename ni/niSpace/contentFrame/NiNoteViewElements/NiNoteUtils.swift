//
//  NiTextFieldUtils.swift
//  ni
//
//  Created by Patrick Lukas on 27/5/24.
//

import Cocoa

func getNewNoteView(frame: NSRect) -> NiNoteView{
	let view = NiNoteView(frame: frame)
	view.backgroundColor = NSColor(.transparent)
	view.insertionPointColor = NSColor.birkin
	
	return view
}
