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
		
		let notionCalAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "4432C460-246D-4A72-A3B8-F84A66C93E05")!, type: ".png")!
		let linearAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "9AA500EF-5D06-49EC-B3E3-D122308BCAD2")!, type: ".png")!
		let gMailAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "76AD3FA8-81D2-4C9D-A5B0-EF190D4F6D81")!, type: ".png")!
		let slackAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "19898FAF-0C66-446E-AB4E-773CF5EBE1E3")!, type: ".png")!
		let postHogAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "31D0446F-5F68-482A-AC81-39EACAFD11AF")!, type: ".png")!
		let figmaAppIcon = fetchImgFromMainBundle(id: UUID(uuidString: "165C18BB-B531-419D-8EB4-8BBFEC4A9308")!, type: ".png")!
		
		hardCodedWebApps = [
			WebAppItem(name: "Linear",
					   icon: linearAppIcon,
					   url: URL(string: "https://linear.app/")!,
					   frameColor: .birkin
					  ),
			WebAppItem(name: "Gmail", 
					   icon: gMailAppIcon,
					   url: URL(string: "https://mail.google.com/mail/u/0/#inbox")!,
					   frameColor: .birkin
					  ),
			WebAppItem(name: "PostHog",
					   icon: postHogAppIcon,
					   url: URL(string: "https://eu.posthog.com/")!,
					   frameColor: .birkin
					  ),
			WebAppItem(name: "Notion Calendar",
					   icon: notionCalAppIcon,
					   url: URL(string: "https://calendar.notion.so")!,
					   frameColor: .birkin
			),
			WebAppItem(name: "Slack",
					   icon: slackAppIcon,
					   url: URL(string: "https://slack.com")!,
					   frameColor: .birkin
					  ),
			WebAppItem(name: "Figma",
					   icon: figmaAppIcon,
					   url: URL(string: "https://www.figma.com")!,
					   frameColor: .birkin
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
