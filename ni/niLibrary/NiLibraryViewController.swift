//
//  NiLibraryViewController.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibraryViewController: NSViewController{
	
	@IBOutlet var classMoviesConnection: NiLibraryConnectionViewElement!
	@IBOutlet var functionalConnection: NiLibraryConnectionViewElement!
	
	init(){
		super.init(nibName: NSNib.Name("NiLibraryView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		view.layer?.cornerRadius = 20.0
		view.layer?.cornerCurve = .continuous
		view.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		
		if let myView = view as? NiLibraryView{
			myView.setHoverStateImgs()
		}
		
//		functionalConnection.mouseDownFunction = showConnectionDetails
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
	}
	
}


