//
//  RoundedRectView.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

final class RoundedRectView: NSView {
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		let backgroundRect = NSMakeRect(NSMinX(bounds), NSMinY(bounds), NSWidth(bounds), NSHeight(bounds))

		let cornerRadius = 10.0
		let windowPath = NSBezierPath()
		let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: cornerRadius, yRadius: cornerRadius)
		windowPath.append(backgroundPath)
	}

	override var frame: NSRect {
		didSet {
			setNeedsDisplay(frame)
		}
	}
}
