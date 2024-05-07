//
//  CFMinimizedView.swift
//  ni
//
//  Created by Patrick Lukas on 7/5/24.
//

import Cocoa

class CFMinimizedView: NSBox{
	
	
	@IBOutlet var listOfTabs: NSStackView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		listOfTabs.wantsLayer = true
		listOfTabs.layer?.cornerRadius = 10
		listOfTabs.layer?.cornerCurve = .continuous
	}
}
