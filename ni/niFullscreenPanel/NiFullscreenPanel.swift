//
//  NiFullscreenPanel.swift
//  ni
//
//  Created by Patrick Lukas on 28/6/24.
//

import Cocoa
import Carbon.HIToolbox

class NiFullscreenPanel: NSPanel{

	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	
	private var windowBlurView: NSView?
	private var contentBlurView: NSView?
	
	init(mainWindow: NSWindow, contentViewController: NiAlertPanelController){
		let contentRect = NiFullscreenPanel.calcContentRect(contentViewController.view.frame.size, screenSize: mainWindow.frame.size)
		let frameRect = NSPanel.rectForScreen(contentRect, screen: mainWindow.screen!)

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
		self.contentViewController = contentViewController
		
		hasShadow = false
		isOpaque = false
		backgroundColor = NSColor.clear
		
		let contentBlurRect = CGRect(
			origin: CGPoint(
				x: contentViewController.contentBox.frame.origin.x + self.frame.origin.x,
				y: contentViewController.contentBox.frame.origin.y + self.frame.origin.y
			),
			size: contentViewController.contentBox.frame.size
		)
		setBlurOnMainWindow(mainWindow, for: contentBlurRect)
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
	
	private func setBlurOnMainWindow(_ mainWindow: NSWindow, for contentRect: CGRect){
		windowBlurView = NSView(frame: mainWindow.frame)
		windowBlurView?.frame.origin = CGPoint(x: 0.0, y: 0.0)
		windowBlurView!.wantsLayer = true
		setupBlurLayerView(windowBlurView!, inputRadius: 1.0, inputSaturation: 0.6)
		
		//needs to happen if the display that is shown on is not main
		let backAdjustedOriginRect = CGRect(
			origin: CGPoint(
				x: contentRect.origin.x - mainWindow.screen!.frame.origin.x,
				y: contentRect.origin.y - mainWindow.screen!.frame.origin.y
			),
			size: contentRect.size)
		contentBlurView = NSView(frame: contentRect)
		contentBlurView!.wantsLayer = true
		setupBlurLayerView(contentBlurView!, inputRadius: 15.0, inputSaturation: 1.0)
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

	override func resignKey() {
		super.resignKey()
		removeSelf()
	}
}
