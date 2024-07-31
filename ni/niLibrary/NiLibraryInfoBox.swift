//
//  NiLibraryInfoBox.swift
//  ni
//
//  Created by Patrick Lukas on 31/7/24.
//

import Cocoa


class NiLibraryInfoBox: NSImageView{
	
	override func mouseDown(with event: NSEvent) {
		self.removeFromSuperview()
	}
}

