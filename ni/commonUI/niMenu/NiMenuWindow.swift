//
//  NiMenuWindow.swift
//  ni
//
//  Created by Patrick Lukas on 6/6/24.
//

import Cocoa

class NiMenuWindow: NSPanel {

	private let niDelegate: NiMenuWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	private var screenToDisplayOn: NSScreen?
	
	init(origin: NSPoint, dirtyMenuItems: [NiMenuItemViewModel?], currentScreen: NSScreen, adjustOrigin: Bool = true, adjustForOutofBounds: Bool = false){
		niDelegate = NiMenuWindowDelegate()
		
		screenToDisplayOn = currentScreen
		
		let cleanMenuItems = NiMenuWindow.removeNilValues(items: dirtyMenuItems)
		let size = NiMenuWindow.calcSize(cleanMenuItems.count)
		var adjustedOrigin = origin
		if(adjustOrigin){
			adjustedOrigin.y = origin.y - size.height
		}
		var frameRect = NSPanel.rectForScreen(NSRect(origin: adjustedOrigin, size: size), screen: currentScreen)
		
		if(adjustForOutofBounds && currentScreen.frame.maxX < frameRect.maxX){
			frameRect.origin.x -= (frameRect.width - 26.0)
		}
		if(adjustForOutofBounds && frameRect.minY < 0){
			frameRect.origin.y += (frameRect.height - 18)
		}
		
		super.init(
			contentRect: frameRect,
			styleMask: NiMenuWindow.getStyleMask(),
			backing: .buffered,
			defer: true
		)
		//set, as otherwise the desktop on the 2nd display will switch to a different desktop if an application is running fullscreen on that display
		collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		delegate = niDelegate
		contentViewController = NiMenuViewController(menuItems: cleanMenuItems, size: size)
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
	}
	
	private static func removeNilValues(items: [NiMenuItemViewModel?]) -> [NiMenuItemViewModel]{
		var cleanItems: [NiMenuItemViewModel] = []
		for item in items{
			if(item == nil){
				continue
			}
			cleanItems.append(item!)
		}
		return cleanItems
	}
	
	static func calcSize(_ nrOfItems: Int) -> CGSize{
		let h = if(nrOfItems == 1){
			40.0 + 20.0 + 20.0	//item + padding + shadow
		}else{
			40.0 * Double(nrOfItems) + 20.0 + 5.0 * Double(nrOfItems - 1) + 20.0
		}
		return CGSize(width: 280.0, height: h)
	}
	
	private static func getStyleMask() -> NSWindow.StyleMask{
		return .borderless
	}
	
	override func cancelOperation(_ sender: Any?) {
		orderOut(nil)
		close()
	}
}
