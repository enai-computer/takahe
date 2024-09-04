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
	let allowESC: Bool
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}

	init(windowToAppearOn: NSWindow, allowESC: Bool = false){
		let homeViewRect = NiHomeWindow.calcHomeViewRect(windowToAppearOn.frame.size)

		self.allowESC = allowESC
		niDelegate = NiHomeWindowDelegate()
		
		super.init(
			contentRect: windowToAppearOn.frame,
			styleMask: .borderless,
			backing: .buffered,
			defer: true
		)
		//set, as otherwise the desktop on the 2nd display will switch to a different desktop if an application is running fullscreen on that display
		collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
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
		resignKey()
		
		//TODO: find out why hover states do not work in main window after homeview dissapeared.
		//place to fix is here

		orderOut(self)
		close()
	}
}
