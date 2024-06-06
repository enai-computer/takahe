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
	
	init(origin: NSPoint, menuItems: [NiMenuItemViewModel]){
		niDelegate = NiMenuWindowDelegate()
		let size = NiMenuWindow.calcSize(menuItems.count)
		var adjustedOrigin = origin
		adjustedOrigin.y = origin.y - size.height
		super.init(
			contentRect: NSRect(
				origin: adjustedOrigin,
				size: size
			),
			styleMask: NiMenuWindow.getStyleMask(),
			backing: .buffered,
			defer: true
//			screen: .main
		)
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		delegate = niDelegate
		contentViewController = NiMenuViewController(menuItems: menuItems, size: size)
		
		hasShadow = true
		isOpaque = false
		backgroundColor = NSColor.clear
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
	

}
