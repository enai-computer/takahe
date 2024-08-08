//
//  NiPinnedMenuViewController.swift
//  ni
//
//  Created by Patrick Lukas on 25/7/24.
//

import Cocoa

class NiPinnedMenuViewController: NSViewController{
	
	let items: [WebAppItem] //FixME
	let spaceDocController: NiSpaceDocumentController
	private let myViewHeight: CGFloat
	
	init(items: [WebAppItem], docController: NiSpaceDocumentController, height: CGFloat) {
		self.items = items
		self.spaceDocController = docController
		self.myViewHeight = height
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		let myView = (NSView.loadFromNib(nibName: "NiPinnedMenuView", owner: self) as! NiPinnedMenuView)
		let viewItems = genMenuItemViews(items: self.items)
		myView.lstOfMenuItems.setViews(viewItems, in: .top)
		myView.frame.origin = NSPoint(x: 10.0, y: 10.0)
		myView.frame.size.height = self.myViewHeight
		view = RoundedRectView(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 68.0, height: self.myViewHeight + 20.0)))
		view.addSubview(myView)
	}

	override func viewWillLayout() {
		super.viewWillLayout()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
	}
	
	//TODO: set up NiActionImages and add to Stack view
	private func genMenuItemViews(items: [WebAppItem]) -> [NSView]{
		var menuItems: [NSView] = []
		
		for item in items{
			let itemView = NiActionImage(
				image: item.icon,
				with: NSSize(width: 28.0, height: 28.0)
			)
			itemView.isActiveFunction = {return true}
			itemView.setMouseDownFunction(item.openWebApp, with: spaceDocController)
			menuItems.append(itemView)
		}
		
		return menuItems
	}
}

extension WebAppItem{
	
	func openWebApp(with event: NSEvent, context: Any){
		if let docController = context as? NiSpaceDocumentController{
			let cfController = docController.openEmptyCF(viewState: .simpleFrame, openInitalTab: false, groupName: self.name)
			
			//TODO: fix me!
			if(webAppView == nil){
				cfController.openWebsiteInNewTab(url.absoluteString, shallSelectTab: true)
//				self.webAppView = cfController.tabs[0].webView
			}else{
				
			}
			
			if let frameView = cfController.myView as? CFSimpleFrameView{
				frameView.changeFrameColor(set: self.frameColor)
			}
			cfController.view.window?.makeKeyAndOrderFront(nil)
		}
	}
}
