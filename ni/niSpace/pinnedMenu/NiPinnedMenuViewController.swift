//
//  NiPinnedMenuViewController.swift
//  ni
//
//  Created by Patrick Lukas on 25/7/24.
//

import Cocoa

class NiPinnedMenuViewController: NSViewController{
	
	let items: [NSView] //FixME
	
	init(items: [NSView]) {
		self.items = items
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let myView = (NSView.loadFromNib(nibName: "NiPinnedMenuView", owner: self) as! NiPinnedMenuView)
		myView.frame.origin = NSPoint(x: 10.0, y: 10.0)
//		myView.frame.size.height = wSize.height - 20.0
		view = RoundedRectView(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 68.0, height: 68.0)))
		view.addSubview(myView)
	}
	
	//TODO: set up NiActionImages and add to Stack view
	
}
