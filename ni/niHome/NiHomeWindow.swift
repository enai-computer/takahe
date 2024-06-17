//
//  NiHomeWindow.swift
//  ni
//
//  Created by Patrick Lukas on 17/6/24.
//

import Cocoa
import Carbon.HIToolbox


class NiHomeWindow: NSPanel{
	
	private let niDelegate: NiHomeWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}

	init(screenToAppearOn: NSScreen){
		let homeViewRect = NiHomeWindow.calcRect(screenToAppearOn.frame.size)
		let frameRect = NSPanel.rectForScreen(homeViewRect, screen: screenToAppearOn)
		
		niDelegate = NiHomeWindowDelegate()
		
		super.init(
			contentRect: frameRect,
			styleMask: .borderless,
			backing: .buffered,
			defer: true
		)
		
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		delegate = niDelegate
		contentViewController = NiHomeController(frame: frameRect)
		
		hasShadow = false
		isOpaque = true
		backgroundColor = NSColor.clear
	}
	
	private static func calcRect(_ screenSize: NSSize) -> NSRect{
		let selfSize = CGSize(
			width: (screenSize.width - 100.0),
			height: (screenSize.height - 83.0))
		return NSRect(origin: CGPoint(x: 50.0, y: 83.0), size: selfSize)
	}
}
