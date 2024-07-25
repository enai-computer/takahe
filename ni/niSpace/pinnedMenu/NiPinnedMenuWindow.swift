//
//  NiPinnedMenuWindow.swift
//  ni
//
//  Created by Patrick Lukas on 25/7/24.
//

import Cocoa

class NiPinnedMenuWindow: NSPanel{
	
	private let niDelegate: NiMenuWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	private var screenToDisplayOn: NSScreen?
	
	init(origin: NSPoint, currentScreen: NSScreen, adjustOrigin: Bool = true, adjustForOutofBounds: Bool = false){
		niDelegate = NiMenuWindowDelegate()
		
		screenToDisplayOn = currentScreen
		
//		let cleanMenuItems = NiMenuWindow.removeNilValues(items: dirtyMenuItems)
//		let size = NiMenuWindow.calcSize(cleanMenuItems.count)
		var adjustedOrigin = origin
//		if(adjustOrigin){
//			adjustedOrigin.y = origin.y - size.height
//		}
		var frameRect = NSPanel.rectForScreen(NSRect(origin: adjustedOrigin, size: CGSize(width: 48.0, height: 48.0)), screen: currentScreen)
		
		if(adjustForOutofBounds && currentScreen.frame.maxX < frameRect.maxX){
			frameRect.origin.x -= (frameRect.width - 26.0)
		}
		if(adjustForOutofBounds && frameRect.minY < 0){
			frameRect.origin.y += (frameRect.height - 18)
		}
		
		super.init(
			contentRect: frameRect,
			styleMask: .borderless,
			backing: .buffered,
			defer: true
		)
		//set, as otherwise the desktop on the 2nd display will switch to a different desktop if an application is running fullscreen on that display
		collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		delegate = niDelegate
		contentViewController = NiPinnedMenuViewController(items: [])
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
	}
}
