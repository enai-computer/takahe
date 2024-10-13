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
				initialTabType: .web,
				openInitalTab: false,
				groupName: itemData.name,
				positionAlwaysCenter: true
			)
			
			
			cfController.openWebsiteInNewTab(
				itemData.url.absoluteString,
				shallSelectTab: true,
				as: .web
			)
			
			if let frameView = cfController.myView as? CFSimpleFrameView{
				if isDarkModeEnabled(){
					frameView.changeFrameColor(set: itemData.darkframeNSColor ?? NSColor.sand4)
				}else{
					frameView.changeFrameColor(set: itemData.frameNSColor ?? NSColor.sand4)

				}
			}
			cfController.view.window?.makeKeyAndOrderFront(nil)
		}
	}

	func getIcon() -> NSImage{
		return self.icon ?? NSImage(named: "AppIcon")!
	}
}
