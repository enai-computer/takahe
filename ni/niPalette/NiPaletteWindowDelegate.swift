//
//  NiPaletteWindowDelegate.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class NiPaletteWindowDelegate: NSObject, NSWindowDelegate{
	
	func windowDidResignKey(_ notification: Notification) {
			if let window = notification.object as? NiPalette {
				window.removeSelf()
			}
		}
	
}
