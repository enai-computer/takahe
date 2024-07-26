//
//  NiPinnedMenuWindow.swift
//  ni
//
//  Created by Patrick Lukas on 25/7/24.
//

import Cocoa

struct WebAppItem{
	let name: String
	let icon: NSImage
	let url: URL
	let frameColor: NSColor
}

class NiPinnedMenuWindow: NSPanel{
	
	private let niDelegate: NiMenuWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	private var screenToDisplayOn: NSScreen?
	
	init(origin: NSPoint, items: [WebAppItem], docController: NiSpaceDocumentController,
		 currentScreen: NSScreen, adjustOrigin: Bool = true, adjustForOutofBounds: Bool = false){
		niDelegate = NiMenuWindowDelegate()
		
		screenToDisplayOn = currentScreen
		
		let size = NiPinnedMenuWindow.calcSize(items.count)
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
			styleMask: NSWindow.StyleMask.borderless,
			backing: .buffered,
			defer: true
		)
		//set, as otherwise the desktop on the 2nd display will switch to a different desktop if an application is running fullscreen on that display
		collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		delegate = niDelegate
		contentViewController = NiPinnedMenuViewController(
			items: items,
			docController: docController,
			height: NiPinnedMenuWindow.calcViewHeight(items.count)
		)
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
	}
	
	private static func calcSize(_ nrOfItems: Int) -> CGSize{
		let h = calcViewHeight(nrOfItems) + 20.0	//contentView + space for a shadow
		return CGSize(width: 68.0, height: h)
	}
	
	private static func calcViewHeight(_ nrOfItems: Int) -> CGFloat{
		return ((28.0 * Double(nrOfItems)) + ((Double(nrOfItems) - 1.0) * 20.0) + 20.0)
	}
	
	override func cancelOperation(_ sender: Any?) {
		orderOut(nil)
		close()
	}
}
