//
//  NiPaletteContentController.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class NiPaletteContentController: NSViewController{
	
	private var paletteSize: NSSize
	private var searchController: NSViewController
	
	init(paletteSize: NSSize) {
		self.paletteSize = paletteSize
		searchController = NiSearchController(style: .palette)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = RoundedRectView(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: paletteSize))
	}
	
	override func viewDidLoad() {
		view.addSubview(searchController.view)
	}
}
