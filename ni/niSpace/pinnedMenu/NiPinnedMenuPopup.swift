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
					   frameColor: NSColor(r: 236.0, g: 236.0, b: 236.0, alpha: 1.0)
					  ),
			WebAppItem(name: "Gmail", 
					   icon: gMailAppIcon,
					   url: URL(string: "https://mail.google.com/mail/u/0/#inbox")!,
					   frameColor: NSColor(r: 235.0, g: 241.0, b: 250.0, alpha: 1.0)
					  ),
			WebAppItem(name: "PostHog",
					   icon: postHogAppIcon,
					   url: URL(string: "https://eu.posthog.com/")!,
					   frameColor: NSColor(r: 238.0, g: 239.0, b: 234.0, alpha: 1.0)
					  ),
			WebAppItem(name: "Notion Calendar",
					   icon: notionCalAppIcon,
					   url: URL(string: "https://calendar.notion.so")!,
					   frameColor: NSColor(r: 247.0, g: 247.0, b: 247.0, alpha: 1.0)
			),
			WebAppItem(name: "Slack",
					   icon: slackAppIcon,
					   url: URL(string: "https://slack.com")!,
					   frameColor: NSColor(r: 76.0, g: 41.0, b: 82.0, alpha: 1.0)
					  ),
			WebAppItem(name: "Figma",
					   icon: figmaAppIcon,
					   url: URL(string: "https://www.figma.com")!,
					   frameColor: NSColor(r: 255.0, g: 255.0, b: 255.0, alpha: 1.0)
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

extension NSColor{
	
	convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat){
		self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
	}
}
