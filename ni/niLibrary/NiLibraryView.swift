//
//  NiLibraryView.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibraryView: NSBox{
	
	@IBOutlet var contentBox: NSView!
	
	
	func hideSpaces(){
		for v in contentBox.subviews{
			if let demoImage = v as? DemoLibraryImage{
				demoImage.tryHide()
			}
		}
	}
}
