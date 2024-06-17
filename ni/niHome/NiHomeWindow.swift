//
//  NiHomeWindow.swift
//  ni
//
//  Created by Patrick Lukas on 17/6/24.
//

import Cocoa
import Carbon.HIToolbox


class NiHomeWindow: NSPanel, NiSearchWindowProtocol{
	
	private let niDelegate: NiHomeWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}

	init(windowToAppearOn: NSWindow){
		let homeViewRect = NiHomeWindow.calcRect(windowToAppearOn.frame.size)
		let frameRect = NSPanel.rectForScreen(homeViewRect, screen: windowToAppearOn.screen!)
		
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
	
	func removeSelf(){
		self.orderOut(nil)
		self.close()
	}
}
