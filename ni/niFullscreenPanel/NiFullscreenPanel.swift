//
//  NiFullscreenPanel.swift
//  ni
//
//  Created by Patrick Lukas on 28/6/24.
//

import Cocoa
import Carbon.HIToolbox

class NiFullscreenPanel: NSPanel{
	
	private let niDelegate: NiPaletteWindowDelegate
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	
	private var windowBlurView: NSView?
	private var contentBlurView: NSView?
	
	init(_ contentViewController: NiAlertPanelController){
		let mainWindow = NSApplication.shared.mainWindow!
		let contentRect = NiFullscreenPanel.calcContentRect(contentViewController.view.frame.size, screenSize: mainWindow.frame.size)
		let frameRect = NSPanel.rectForScreen(contentRect, screen: mainWindow.screen!)
		
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
		self.contentViewController = contentViewController
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
		setBlurOnMainWindow(mainWindow, with: contentViewController.panelContet.frame)
	}
	
	private static func calcContentRect(_ contentSize: NSSize, screenSize: NSSize) -> NSRect{
		//center on x
		let distToLeftBorder = (screenSize.width - contentSize.width) / 2
		//18% down from top
		let distToBottomBorder = screenSize.height - (screenSize.height * 0.18024) - contentSize.height
		
		return NSRect(
			x: distToLeftBorder,
			y: distToBottomBorder,
			width: contentSize.width,
			height: contentSize.height
		)
	}
	
	private func setBlurOnMainWindow(_ mainWindow: NSWindow, with contentRect: CGRect){
		windowBlurView = NSView(frame: mainWindow.frame)
		windowBlurView?.frame.origin = CGPoint(x: 0.0, y: 0.0)
		windowBlurView!.wantsLayer = true
		setupBlurLayerView(windowBlurView!, inputRadius: 1.0, inputSaturation: 0.6)
		
		contentBlurView = NSView(frame: contentRect)
		contentBlurView!.wantsLayer = true
		setupBlurLayerView(contentBlurView!, inputRadius: 30.0, inputSaturation: 1.0)
		contentBlurView?.layer?.cornerRadius = 15.0
		
		mainWindow.contentView!.addSubview(windowBlurView!)
		mainWindow.contentView!.addSubview(contentBlurView!)
		
		windowBlurView!.layer?.needsDisplay()
		contentBlurView?.layer?.needsDisplay()
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
		contentBlurView?.removeFromSuperview()
		contentBlurView = nil
		self.orderOut(nil)
		self.close()
	}
}
