//
//  NiPinnedMenuPopup.swift
//  ni
//
//  Created by Patrick Lukas on 25/7/24.
//

import Cocoa

class NiPinnedMenuPopup: NSObject{
	
	private let hardCodedWebApps: [WebAppItem]
	private let docController: NiSpaceDocumentController
	
	init(with docController: NiSpaceDocumentController) {
		self.docController = docController
		let whatsAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "0DF11B3D-FD70-47A3-9D86-AF0189F1E1E3")!, type: ".png")!
		let notionAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "C8F62C3A-3A6C-4679-9D6B-1170A2285100")!, type: ".png")!
		let linearAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "EDC4FB2E-538C-4B59-802A-D607CC5D2525")!, type: ".png")!
		hardCodedWebApps = [
			WebAppItem(name: "WhatsApp",
						  icon: whatsAppIcon,
						  url: URL(string: "https://web.whatsapp.com/")!
						 ),
			WebAppItem(name: "Notion",
					   icon: notionAppIcon,
					   url: URL(string:"https://www.notion.so/")!),
			WebAppItem(name: "Linear",
					   icon: linearAppIcon,
					   url: URL(string: "https://linear.app/")!
			)
		]
	}
	
	func displayPopupWindow(_ referencePoint: CGPoint, screen: NSScreen) -> NiPinnedMenuWindow {
		let adjustedPos = CGPoint(
			x: referencePoint.x - 33.0,
			y: referencePoint.y - 5.0
		)
		let menuWindow = NiPinnedMenuWindow(
			origin: adjustedPos,
			items: hardCodedWebApps, 
			docController: self.docController,
			currentScreen: screen
		)
		menuWindow.makeKeyAndOrderFront(nil)
		return menuWindow
	}
}
