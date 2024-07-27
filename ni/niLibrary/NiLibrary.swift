//
//  NiLibrary.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibrary: NSPanel{
	
	private let niDelegate: NiPaletteWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	
	private var windowBlurView: NSView?

	init(){
		let mainWindow = NSApplication.shared.mainWindow!
		let paletteRect = NiLibrary.calcPaletteRect(mainWindow.frame.size)
		let frameRect = NSPanel.rectForScreen(paletteRect, screen: mainWindow.screen!)
		
		niDelegate = NiPaletteWindowDelegate()
		
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
		contentViewController = NiPaletteContentController(paletteSize: paletteRect.size)
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
		setBlurOnMainWindow(mainWindow)
	}
	
	private func setBlurOnMainWindow(_ mainWindow: NSWindow){
		windowBlurView = NSView(frame: mainWindow.frame)
		windowBlurView?.frame.origin = CGPoint(x: 0.0, y: 0.0)
		windowBlurView!.wantsLayer = true
		setupBlurOnView(windowBlurView!, inputRadius: 1.0, inputSaturation: 0.6)
		
		//needs to happen if the display that is shown on is not main
		let backAdjustedOriginRect = CGRect(
			origin: CGPoint(
				x: self.frame.origin.x - mainWindow.screen!.frame.origin.x,
				y: self.frame.origin.y - mainWindow.screen!.frame.origin.y
			),
			size: self.frame.size)
		
		mainWindow.contentView!.addSubview(windowBlurView!)
	
		windowBlurView!.layer?.needsDisplay()
	}
	
	private static func calcPaletteRect(_ screenSize: NSSize) -> NSRect{
		let w = 586.0
		let h = 426.0
		
		//center on x
		let distToLeftBorder = (screenSize.width - w) / 2
		//18% down from top
		let distToBottomBorder = screenSize.height - (screenSize.height * 0.18024) - h
		
		return NSRect(
			x: distToLeftBorder,
			y: distToBottomBorder,
			width: w,
			height: h
		)
	}
}
