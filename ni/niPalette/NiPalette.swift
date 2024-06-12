//
//  NiPalette.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa
import Carbon.HIToolbox

class NiPalette: NSPanel {
	
	private let niDelegate: NiPaletteWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	
	private var blurView: NSView?
	
	init(){
		let mainWindow = NSApplication.shared.mainWindow!
		let frameRect = NSPanel.rectForScreen(NSRect(origin: NSPoint(x: 0.0, y: 0.0), size: mainWindow.frame.size), screen: mainWindow.screen!)
		
		niDelegate = NiPaletteWindowDelegate()
		
		super.init(
			contentRect: frameRect,
			styleMask: .borderless,
			backing: .buffered,
			defer: true
		)
		
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		delegate = niDelegate
		contentViewController = NiPaletteContentController(windowSize: frameRect)
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
		
		setBlurOnMainWindow(mainWindow)
	}
	
	private func setBlurOnMainWindow(_ mainWindow: NSWindow){
		blurView = NSView(frame: mainWindow.frame)
		blurView!.wantsLayer = true
		blurView!.layer?.backgroundColor = NSColor.clear.cgColor
		blurView!.layer?.masksToBounds = true
		blurView!.layerUsesCoreImageFilters = true
		blurView!.layer?.needsDisplayOnBoundsChange = true

		let satFilter = CIFilter(name: "CIColorControls")!
		satFilter.setDefaults()
		satFilter.setValue(NSNumber(value: 0.6), forKey: "inputSaturation")

		let blurFilter = CIFilter(name: "CIGaussianBlur")!
		blurFilter.setDefaults()
		blurFilter.setValue(NSNumber(value: 1.0), forKey: "inputRadius")

		blurView!.layer?.backgroundFilters = [satFilter, blurFilter]
		mainWindow.contentView!.addSubview(blurView!)

		blurView!.layer?.needsDisplay()
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
		blurView?.removeFromSuperview()
		blurView = nil
		self.orderOut(nil)
		self.close()
	}
}

