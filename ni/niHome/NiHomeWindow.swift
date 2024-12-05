//
//  NiHomeWindow.swift
//  ni
//
//  Created by Patrick Lukas on 17/6/24.
//

import Cocoa
import Carbon.HIToolbox


class NiHomeWindow: NSPanel, NiSearchWindowProtocol{
	
	let canBeDismissed: Bool
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}

	private let myViewController: NiHomeController
	
	init(windowToAppearOn: NSWindow, canBeDismissed: Bool = false){

		self.canBeDismissed = canBeDismissed
		self.myViewController = NiHomeController(frame: NSRect(origin: .zero, size: windowToAppearOn.frame.size))
												 
		super.init(
			contentRect: windowToAppearOn.frame,
			styleMask: [
				.borderless,
				.nonactivatingPanel,
				.utilityWindow,
			],
			backing: .buffered,
			defer: true
		)
		//set, as otherwise the desktop on the 2nd display will switch to a different desktop if an application is running fullscreen on that display
		collectionBehavior = [
			.auxiliary, .fullScreenAuxiliary,
			// Stationary is required to prevent flickering of this window and the default window when switching out of, and back to, this app with ⌘+Tab.
			.stationary,
		]
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		contentViewController = NiEmptyViewController(
			viewFrame: windowToAppearOn.frame,
			contentController: myViewController)

		hasShadow = false
		isOpaque = false
		isFloatingPanel = true
		backgroundColor = NSColor.clear
		hidesOnDeactivate = false
	}

	override func cancelOperation(_ sender: Any?) {
		guard canBeDismissed else {
			NSSound.beep()
			return
		}
		removeSelf()
	}

	func removeSelf(){
		resignKey()
		
		//TODO: find out why hover states do not work in main window after homeview dissapeared.
		//place to fix is here

		orderOut(self)
		close()
	}
}
