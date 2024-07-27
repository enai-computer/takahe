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
		let paletteRect = NiLibrary.calcLibraryRect(mainWindow.frame.size)
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
//		delegate = niDelegate
		contentViewController = NiLibraryViewController()
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
		setBlurOnMainWindow(mainWindow)
	}
	
	func removeSelf(){
		windowBlurView?.removeFromSuperview()
		windowBlurView = nil
		self.orderOut(nil)
		self.close()
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
	
	private static func calcLibraryRect(_ screenSize: NSSize) -> NSRect{
		let w = screenSize.width - (56.0 * 2.0)
		let h = screenSize.height - 56.0
		
		return NSRect(
			x: 56.0,
			y: 0,
			width: w,
			height: h
		)
	}
}
