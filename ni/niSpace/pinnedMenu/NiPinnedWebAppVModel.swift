//
//  NiPinnedMenuVModel.swift
//  ni
//
//  Created by Patrick Lukas on 9/8/24.
//

import Cocoa

private let HOW_TO_LINK = "https://enai.notion.site/How-to-use-pinned-Apps-cef61416cfaa48fc83099d818f81c3ff"

func loadPinnedWebApps() async -> [NiPinnedWebAppVModel]{
	var apps: [NiPinnedWebAppVModel] = []
	
	for webAppConfig in UserSettings.shared.pinnedWebApps{
		let webAppVM = NiPinnedWebAppVModel(for: webAppConfig)
		await webAppVM.loadIcon()
		apps.append(webAppVM)
	}
	
	if(apps.isEmpty){
		let webAppVM = NiPinnedWebAppVModel(
			for: WebAppItemModel(
				name: "How to use pinned Apps",
				url: URL(string: HOW_TO_LINK)!
			)
		)
		await webAppVM.loadIcon()
		apps.append(webAppVM)
	}
	
	return apps
}

func getNewPinnedWebApp(name: String, url: URL) async -> (NiPinnedWebAppVModel, WebAppItemModel){
	let model = WebAppItemModel(name: name, url: url)
	let vModel = NiPinnedWebAppVModel(for: model)
	await vModel.loadIcon()
	return (vModel, model)
}

class NiPinnedWebAppVModel{
	
	let itemData: WebAppItemModel
	private var icon: NSImage?
	var webView: NiWebView?
	
	init(for item: WebAppItemModel) {
		self.itemData = item
	}
	
	func loadIcon() async{
		self.icon = await FaviconProvider.instance.fetchIcon(itemData.url.absoluteString)
	}
	
	func openWebApp(with event: NSEvent, context: Any){
		if let docController = context as? NiSpaceDocumentController{
			let cfController = docController.openEmptyCF(
				viewState: .simpleFrame,
				initialTabType: .webApp,
				openInitalTab: false,
				groupName: itemData.name
			)
			
			if(webView == nil){
				cfController.openWebsiteInNewTab(
					itemData.url.absoluteString,
					shallSelectTab: true,
					as: .webApp
				)
				self.webView = cfController.tabs[0].webView
			}else{
				openWebViewFromCache(cfController, with: webView!)
			}
			
			if let frameView = cfController.myView as? CFSimpleFrameView{
				frameView.changeFrameColor(set: itemData.frameNSColor ?? NSColor.sand4)
			}
			cfController.view.window?.makeKeyAndOrderFront(nil)
		}
	}
	
	private func openWebViewFromCache(
		_ cfController: ContentFrameController,
		with webView: NiWebView
	){
		_ = cfController.myView.createNewTab(tabView: webView)
		webView.owner = cfController
		
		var tabHeadModel = TabViewModel(contentId: UUID(), type: .webApp)
		tabHeadModel.position = 0
		tabHeadModel.viewItem = webView
		tabHeadModel.webView!.tabHeadPosition = tabHeadModel.position
		tabHeadModel.state = .loaded
	}
	
	func getIcon() -> NSImage{
		return self.icon ?? NSImage(named: "AppIcon")!
	}
}
