//
//  NiMenuViewController.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa


class NiMenuViewController: NSViewController{
	
	let items: [NiMenuItemViewModel]
	let wSize: CGSize
	
	init(menuItems: [NiMenuItemViewModel], size: CGSize){
		items = menuItems
		wSize = size
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let myView = (NSView.loadFromNib(nibName: "NiMenuView", owner: self) as! NiMenuView)
		let menuItems = genMenuItemViews(items: items)
		myView.lstOfMenuItems.setViews(menuItems, in: .top)
		myView.frame.origin = NSPoint(x: 10.0, y: 13.0)
		myView.frame.size.height = wSize.height - 20.0
		view = RoundedRectView(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: wSize))
		view.addSubview(myView)
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
	}
	
	private func genMenuItemViews(items: [NiMenuItemViewModel]) -> [NiMenuItemView]{
		var menuItems: [NiMenuItemView] = []
		
		for item in items{
			let itemView = (NSView.loadFromNib(nibName: "NiMenuItemView", owner: self) as! NiMenuItemView)
			itemView.display(viewModel: item)
			menuItems.append(itemView)
		}
		
		return menuItems
	}
}
