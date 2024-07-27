//
//  NiLibraryViewController.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibraryViewController: NSViewController{
	
	override func loadView() {
		view = (NSView.loadFromNib(nibName: "NiLibraryView", owner: self) as! NiLibraryView)
	}
}
