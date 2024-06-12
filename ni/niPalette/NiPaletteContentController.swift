//
//  NiPaletteContentController.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class NiPaletteContentController: NSViewController{
	
	private var size: NSRect?
	private var searchController: NSViewController
	
	init(windowSize: NSRect) {
		size = windowSize
		searchController = NiSearchController(nibName: NSNib.Name("NiSearchView"), bundle: Bundle.main)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = NSView(frame: size!)
//		view.wantsLayer = true
//		view.layer?.backgroundColor = NSColor.black.cgColor
//		
//		searchController.loadView()
	}
	
	override func viewDidLoad() {
		let subView = NSView(frame: NSRect(x: 500, y: 500, width: 500, height: 500))
		subView.wantsLayer = true
		subView.layer?.backgroundColor = NSColor.birkin.cgColor
		subView.alphaValue = 1.0
		view.addSubview(subView)
		
//		positionSubview(searchController.view)
//		
//		view.addSubview(searchController.view)
	}
	
	private func positionSubview(_ subView: NSView){
		let distToTop = view.frame.height * 0.18024
		subView.addConstraint(NSLayoutConstraint(
			item: subView,
			attribute: .top,
			relatedBy: .equal, 
			toItem: self.view,
			attribute: .top,
			multiplier: 1.0,
			constant: distToTop))
		
		let distToLeftBoarder = (view.frame.width - subView.frame.width)/2
		subView.addConstraint(NSLayoutConstraint(
			item: subView,
			attribute: .left,
			relatedBy: .equal,
			toItem: self.view,
			attribute: .left, 
			multiplier: 1.0,
			constant: distToLeftBoarder
		))
		
	}
}
