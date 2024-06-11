//
//  NiSpaceMenuView.swift
//  ni
//
//  Created by Patrick Lukas on 20/5/24.
//

import Cocoa

class NiSpaceMenuView: NSBox {

	@IBOutlet var openAWindow: NiSpaceMenuItemView!
	@IBOutlet var writeANote: NiSpaceMenuItemView!
	@IBOutlet var uploadAnImage: NiSpaceMenuItemView!
	@IBOutlet var pasteImgORtxt: NSTextField!
	
	func updatePasteMenuItem(for content: NiPasteboardContent){
		if(content == .empty){
			pasteImgORtxt.textColor = NSColor.sand8
			uploadAnImage.isEnabled = false
		}else if(content == .image){
			pasteImgORtxt.stringValue = "Paste an image"
		}else if(content == .txt){
			pasteImgORtxt.stringValue = "Paste text"
		}
	}
}
