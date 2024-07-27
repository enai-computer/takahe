//
//  NiLibraryViewController.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibraryViewController: NSViewController{
	
	@IBOutlet var connector: NiLibraryConnectionViewElement!
	
	init(){
		super.init(nibName: NSNib.Name("NiLibraryView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		view.layer?.cornerRadius = 20.0
		view.layer?.cornerCurve = .continuous
		view.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
	}
	
	override func viewWillAppear() {
		connector.needsDisplay = true
		connector.diagonal.needsDisplay = true
	}
}
