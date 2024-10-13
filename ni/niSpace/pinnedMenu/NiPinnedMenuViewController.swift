//
//  NiPinnedMenuViewController.swift
//  ni
//
//  Created by Patrick Lukas on 25/7/24.
//

import Cocoa

class NiPinnedMenuViewController: NSViewController{
	
	let items: [NiPinnedWebsiteVModel]
	private weak var spaceDocController: NiSpaceDocumentController?
	private let myViewHeight: CGFloat
	
	private var myContentView: NiPinnedMenuView?
	
	init(items: [NiPinnedWebsiteVModel], docController: NiSpaceDocumentController?, height: CGFloat) {
		self.items = items
		self.spaceDocController = docController
		self.myViewHeight = height
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		myContentView = (NSView.loadFromNib(nibName: "NiPinnedMenuView", owner: self) as! NiPinnedMenuView)
		let viewItems = genMenuItemViews(items: self.items)
		myContentView?.lstOfMenuItems.setViews(viewItems, in: .top)
		myContentView?.frame.origin = NSPoint(x: 10.0, y: 10.0)
		myContentView?.frame.size.height = self.myViewHeight
		view = RoundedRectView(frame: NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 68.0, height: self.myViewHeight + 20.0)))
		view.addSubview(myContentView!)
	}

	override func viewWillLayout() {
		super.viewWillLayout()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
	}
	
	private func genMenuItemViews(items: [NiPinnedWebsiteVModel]) -> [NSView]{
		var menuItems: [NSView] = []
		
		for item in items{
			let itemView = NiActionImage(
				image: item.getIcon(),
				with: NSSize(width: 28.0, height: 28.0)
			)
			itemView.isActiveFunction = {return true}
			itemView.setMouseDownFunction(item.openWebsite, with: spaceDocController)
			let trackingRect = CGRect(
				origin: CGPoint(x: itemView.frame.origin.x, y: itemView.frame.origin.y + 7.0),
				size: CGSize(width: itemView.frame.width + 5.0, height: itemView.frame.height + 5.0)
			)
			let hoverEffect = NSTrackingArea.init(rect: trackingRect, options: [.mouseEnteredAndExited, .activeInKeyWindow], owner: self, userInfo: ["triggeredOn":itemView, "itemData": item])
			itemView.addTrackingArea(hoverEffect)
			menuItems.append(itemView)
		}
		
		return menuItems
	}
	
	override func mouseEntered(with event: NSEvent){
		guard let referenceIcon: NiActionImage = event.trackingArea?.userInfo?["triggeredOn"] as? NiActionImage else{return}
		guard let deleteIcon = NiActionImage(namedImage: "minusCircle", with: NSSize(width: 16.0, height: 16.0)) else{return}
		guard let itemViewModel: NiPinnedWebsiteVModel = event.trackingArea?.userInfo?["itemData"] as? NiPinnedWebsiteVModel else{return}
		deleteIcon.isActiveFunction = {return true}
		deleteIcon.setMouseDownFunction(self.removeFromPinnedMenu, with: (referenceIcon, itemViewModel) as Any)
		let deleteOrigin = CGPoint(
			x: (referenceIcon.bounds.maxX - 11.0),
			y: (referenceIcon.bounds.maxY - 11.0)
		)
		deleteIcon.frame.origin = deleteOrigin
		referenceIcon.addSubview(deleteIcon)
	}
	
	override func mouseExited(with event: NSEvent){
		guard let referenceIcon: NiActionImage = event.trackingArea?.userInfo?["triggeredOn"] as? NiActionImage else{return}
		for subV in referenceIcon.subviews{
			if let actionImg = subV as? NiActionImage{
				actionImg.removeFromSuperview()
				actionImg.deinitSelf()
			}
		}
	}
	
	func removeFromPinnedMenu(with event: NSEvent, with context: Any){
		guard let spaceController: NiSpaceViewController = (NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController() else {return}
		guard let passedData = context as? (NiActionImage, NiPinnedWebsiteVModel) else{return}
		passedData.0.removeFromSuperview()
		spaceController.removePinnedWebApp(passedData.1)
	}
}

