//
//  NiPinnedWebsiteVModel.swift
//  ni
//
//  Created by Patrick Lukas on 9/8/24.
//

import Cocoa

private let HOW_TO_LINK = "https://enai.notion.site/How-to-use-pinned-Apps-cef61416cfaa48fc83099d818f81c3ff"

func loadPinnedWebsites() async -> [NiPinnedWebsiteVModel]{
	var websites: [NiPinnedWebsiteVModel] = []
	
	for webAppConfig in UserSettings.shared.pinnedWebsites{
		let websiteVM = NiPinnedWebsiteVModel(for: webAppConfig)
		await websiteVM.loadIcon()
		websites.append(websiteVM)
	}
	
	if(websites.isEmpty){
		let webAppVM = NiPinnedWebsiteVModel(
			for: PinnedWebsiteItemModel(
				name: "How to use pinned Apps",
				url: URL(string: HOW_TO_LINK)!
			)
		)
		await webAppVM.loadIcon()
		websites.append(webAppVM)
	}
	
	return websites
}

func getNewPinnedWebsite(name: String, url: URL) async -> (NiPinnedWebsiteVModel, PinnedWebsiteItemModel){
	let model = PinnedWebsiteItemModel(name: name, url: url)
	let vModel = NiPinnedWebsiteVModel(for: model)
	await vModel.loadIcon()
	return (vModel, model)
}

class NiPinnedWebsiteVModel: NSObject{
	
	let itemData: PinnedWebsiteItemModel
	private var icon: NSImage?
	
	init(for item: PinnedWebsiteItemModel) {
		self.itemData = item
	}
	
	func loadIcon() async{
		self.icon = await FaviconProvider.instance.fetchIcon(itemData.url.absoluteString)
	}
	
	static func == (lhs: NiPinnedWebsiteVModel, rhs: NiPinnedWebsiteVModel) -> Bool {
		return lhs.itemData.url == rhs.itemData.url && lhs.itemData.name == rhs.itemData.name
	}
	
	func openWebsite(with event: NSEvent, context: Any){
		if let docController = context as? NiSpaceDocumentController{
			let cfController = docController.openEmptyCF(
				viewState: .simpleFrame,
				initialTabType: .webApp,
				openInitalTab: false,
				groupName: itemData.name,
				positionAlwaysCenter: true
			)
			
			
			cfController.openWebsiteInNewTab(
				itemData.url.absoluteString,
				shallSelectTab: true,
				as: .webApp
			)
			
			if let frameView = cfController.myView as? CFSimpleFrameView{
				frameView.changeFrameColor(set: itemData.frameNSColor ?? NSColor.sand4)
			}
			cfController.view.window?.makeKeyAndOrderFront(nil)
		}
	}

	func showDeleteIcon(with event: NSEvent, context: Any){
		guard let referenceIcon: NiActionImage = context as? NiActionImage else{return}
		guard let deleteIcon = NiActionImage(namedImage: "closeCircle") else{return}
		deleteIcon.isActiveFunction = {return true}
		deleteIcon.setMouseDownFunction(self.removeFromPinnedMenu, with: referenceIcon as Any)
		let deleteOrigin = CGPoint(
			x: (referenceIcon.bounds.maxX - 11.0),
			y: (referenceIcon.bounds.maxY - 11.0)
		)
		deleteIcon.frame.origin = deleteOrigin
		referenceIcon.addSubview(deleteIcon)
	}
	
	func removeFromPinnedMenu(with event: NSEvent, with context: Any){
		guard let spaceController: NiSpaceViewController = (NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController() else {return}
		guard let referenceIcon: NiActionImage = context as? NiActionImage else{return}
		referenceIcon.removeFromSuperview()
		spaceController.removePinnedWebApp(self)
	}

	func getIcon() -> NSImage{
		return self.icon ?? NSImage(named: "AppIcon")!
	}
}
