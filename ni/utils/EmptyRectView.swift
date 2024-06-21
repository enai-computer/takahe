//
//  EmptyRectView.swift
//  ni
//
//  Created by Patrick Lukas on 21/6/24.
//

import Cocoa

final class EmptyRectView: NSView {
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		let backgroundRect = NSMakeRect(NSMinX(bounds), NSMinY(bounds), NSWidth(bounds), NSHeight(bounds))

		let windowPath = NSBezierPath()
		let backgroundPath = NSBezierPath(rect: backgroundRect)
		windowPath.append(backgroundPath)
	}

	override var frame: NSRect {
		didSet {
			setNeedsDisplay(frame)
		}
	}
}
