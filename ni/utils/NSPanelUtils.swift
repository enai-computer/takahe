//
//  NSPanelUtils.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

extension NSPanel{
	
	static func rectForScreen(_ frameRect: NSRect, screen: NSScreen) -> NSRect {
		let frameOrigin = NSPoint(
			x: screen.frame.origin.x + frameRect.origin.x,
			y: screen.frame.origin.y + frameRect.origin.y)
		return NSRect(origin: frameOrigin, size: frameRect.size)
	}
}
