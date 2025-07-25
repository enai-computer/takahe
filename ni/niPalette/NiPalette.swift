//
//  NiPalette.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa
import Carbon.HIToolbox

class NiPalette: NSPanel, NiSearchWindowProtocol {

	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	
	private var windowBlurView: WindowBlurView?
	private var paletteBlurView: NSView?
	
	init(_ mainWindow: NSWindow){
		let paletteRect = NiPalette.calcPaletteRect(mainWindow.frame.size)
		let frameRect = NSPanel.rectForScreen(paletteRect, screen: mainWindow.screen!)

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
		contentViewController = NiPaletteContentController(paletteSize: paletteRect.size)
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
		setBlurOnMainWindow(mainWindow)
	}
	
	private static func calcPaletteRect(_ screenSize: NSSize) -> NSRect{
		let w = 650.0
		let h = 431.0
		
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
	
	private func setBlurOnMainWindow(_ mainWindow: NSWindow){
		windowBlurView = WindowBlurView(frame: mainWindow.frame)
		windowBlurView?.niPalette = self
		
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
		paletteBlurView = NSView(frame: backAdjustedOriginRect)
		paletteBlurView!.wantsLayer = true
		setupBlurOnView(paletteBlurView!, inputRadius: 8.0, inputSaturation: 1.0)
		paletteBlurView?.layer?.cornerRadius = 15.0
		
		mainWindow.contentView!.addSubview(windowBlurView!)
		mainWindow.contentView!.addSubview(paletteBlurView!)
		
		windowBlurView!.layer?.needsDisplay()
		paletteBlurView?.layer?.needsDisplay()
	}
	
	override func cancelOperation(_ sender: Any?) {
		removeSelf()
	}
	
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Escape){
			removeSelf()
		}
	}

	func removeSelf(){
		windowBlurView?.removeFromSuperview()
		windowBlurView = nil
		paletteBlurView?.removeFromSuperview()
		paletteBlurView = nil
		self.orderOut(nil)
		self.close()
	}

	override func resignKey() {
		super.resignKey()
		removeSelf()
	}
}
