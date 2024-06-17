//
//  NiPalette.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa
import Carbon.HIToolbox

class NiPalette: NSPanel, NiSearchWindowProtocol {
	
	private let niDelegate: NiPaletteWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	
	private var blurView: NSView?
	
	init(){
		let mainWindow = NSApplication.shared.mainWindow!
		let paletteRect = NiPalette.calcPaletteRect(mainWindow.frame.size)
		let frameRect = NSPanel.rectForScreen(paletteRect, screen: mainWindow.screen!)
		
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
		contentViewController = NiPaletteContentController(paletteSize: paletteRect.size)
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
		
		setBlurOnMainWindow(mainWindow)
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
	
	private func setBlurOnMainWindow(_ mainWindow: NSWindow){
		blurView = NSView(frame: mainWindow.frame)
		blurView?.frame.origin = CGPoint(x: 0.0, y: 0.0)
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

