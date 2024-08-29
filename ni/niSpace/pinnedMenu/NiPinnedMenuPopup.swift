//
//  NiPinnedMenuPopup.swift
//  ni
//
//  Created by Patrick Lukas on 25/7/24.
//

import Cocoa

class NiPinnedMenuPopup: NSObject{
	
	private let hardCodedWebsites: [NiPinnedWebsiteVModel]
	private weak var docController: NiSpaceDocumentController?
	
	init(with docController: NiSpaceDocumentController, containing sites: [NiPinnedWebsiteVModel]) {
		self.docController = docController
		self.hardCodedWebsites = sites
	}
	
	func displayPopupWindow(_ referencePoint: CGPoint, screen: NSScreen) -> NiPinnedMenuWindow {
		let adjustedPos = CGPoint(
			x: referencePoint.x - 33.0,
			y: referencePoint.y - 5.0
		)
		let menuWindow = NiPinnedMenuWindow(
			origin: adjustedPos,
			items: hardCodedWebsites, 
			docController: self.docController,
			currentScreen: screen
		)
		menuWindow.makeKeyAndOrderFront(nil)
		return menuWindow
	}
}
