//
//  NiActionImage.swift
//  ni
//
//  Created by Patrick Lukas on 29/4/24.
//

import Cocoa


class NiActionImage: NSImageView{
	
	var mouseDownFunction: ((NSEvent) -> Void)?

	override func mouseDown(with event: NSEvent) {
		if (mouseDownFunction != nil){
			mouseDownFunction!(event)
		}
	}
}
