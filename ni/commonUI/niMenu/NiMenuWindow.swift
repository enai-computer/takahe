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
//	override var screen: NSScreen? {return screenToDisplayOn}
	
	
	init(origin: NSPoint, dirtyMenuItems: [NiMenuItemViewModel?], currentScreen: NSScreen){
		niDelegate = NiMenuWindowDelegate()
		
		screenToDisplayOn = currentScreen
		
		let cleanMenuItems = NiMenuWindow.removeNilValues(items: dirtyMenuItems)
		let size = NiMenuWindow.calcSize(cleanMenuItems.count)
		var adjustedOrigin = origin
		adjustedOrigin.y = origin.y - size.height
		let frameRect = NiMenuWindow.rectForScreen(NSRect(origin: adjustedOrigin, size: size), screen: currentScreen)
		super.init(
			contentRect: frameRect,
			styleMask: NiMenuWindow.getStyleMask(),
			backing: .buffered,
			defer: true
		)
		
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		delegate = niDelegate
		contentViewController = NiMenuViewController(menuItems: cleanMenuItems, size: size)
		
		hasShadow = true
		isOpaque = false
		backgroundColor = NSColor.clear
		
	}
	
	private static func rectForScreen(_ frameRect: NSRect, screen: NSScreen) -> NSRect {
		let frameOrigin = NSPoint(
			x: screen.frame.origin.x + frameRect.origin.x,
			y: screen.frame.origin.y + frameRect.origin.y)
		return NSRect(origin: frameOrigin, size: frameRect.size)
	}
	
	override func setFrameOrigin(_ point: NSPoint){
		super.setFrameOrigin(screenToDisplayOn!.frame.origin)
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
	
	private static func calcSize(_ nrOfItems: Int) -> CGSize{
		let h = if(nrOfItems == 1){
			40.0 + 20.0 + 10.0
		}else{
			40.0 * Double(nrOfItems) + 20.0 + 5.0 * Double(nrOfItems - 1) + 10.0
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
