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
		let homeViewRect = NiHomeWindow.calcHomeViewRect(windowToAppearOn.frame.size)

		niDelegate = NiHomeWindowDelegate()
		
		super.init(
			contentRect: windowToAppearOn.frame,
			styleMask: .borderless,
			backing: .buffered,
			defer: true
		)
		
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		delegate = niDelegate
		contentViewController = NiEmptyViewController(viewFrame: windowToAppearOn.frame,
											contentController: NiHomeController(frame: homeViewRect))

		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
		hidesOnDeactivate = false
	}
	
	private static func calcHomeViewRect(_ screenSize: NSSize) -> NSRect{
		let selfSize = screenSize
		return NSRect(origin: CGPoint(x: 0.0, y: 0.0), size: selfSize)
	}
	
	func removeSelf(){
		self.orderOut(nil)
		self.close()
	}
}
