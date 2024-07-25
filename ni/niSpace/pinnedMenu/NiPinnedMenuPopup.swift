//
//  NiPinnedMenuPopup.swift
//  ni
//
//  Created by Patrick Lukas on 25/7/24.
//

import Cocoa

class NiPinnedMenuPopup: NSObject{
	
	static func displayPopupWindow(event: NSEvent, screen: NSScreen) -> NiPinnedMenuWindow {
		let adjustedPos = CGPoint(
			x: event.locationInWindow.x - 13.0,
			y: event.locationInWindow.y + 9.0
		)
		let menuWindow = NiPinnedMenuWindow(origin: adjustedPos, currentScreen: screen)
		return menuWindow
	}
}
