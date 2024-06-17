//
//  NiHomeController.swift
//  ni
//
//  Created by Patrick Lukas on 17/6/24.
//

import Cocoa

class NiHomeController: NSViewController {

	@IBOutlet var leftSide: NSView!
	@IBOutlet var rightSide: NSView!
	@IBOutlet var welcomeTxt: NSTextField!
	
	private var searchController: NiSearchController
	private let viewFrame: NSRect
	
	init(frame: NSRect) {
		self.viewFrame = frame
		self.searchController = NiSearchController(nibName: NSNib.Name("NiSearchView"), bundle: Bundle.main)
		super.init(nibName: NSNib.Name("NiHomeView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.view.frame = viewFrame
		
		setWelcomeMessage()
		styleLeftSide()
		styleRightSide()
		
		positionAndDisplaySearchView()
    }
	
	private func positionAndDisplaySearchView(){
		let posY = (welcomeTxt.frame.maxY - searchController.view.frame.height)
		let posX = rightSide.frame.origin.x + 100.0
		searchController.view.frame.origin = CGPoint(x: posX, y: posY)
		
		self.view.addSubview(searchController.view)
		view.window?.makeFirstResponder(searchController.searchField)
	}
	
	private func setWelcomeMessage(){
		welcomeTxt.stringValue = "\(getWelcomeMessage()) \(NSUserName())"
	}
    
	private func styleLeftSide(){
		leftSide.wantsLayer = true
		leftSide.layer?.backgroundColor = NSColor.sand1.cgColor
	}
	
	private func styleRightSide(){
		rightSide.wantsLayer = true
		rightSide.layer?.backgroundColor = NSColor.sand3.cgColor
	}
}
