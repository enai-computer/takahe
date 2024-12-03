//
//  niOnboardingWindow.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import Cocoa
import Carbon.HIToolbox

class NiOnboardingWindow: NSPanel{

	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}
	
	private var myViewController: NiOnboardingViewController?
	
	init(windowToAppearOn: NSWindow){
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
		let myViewController = NiOnboardingViewController(
			frame: NSRect(origin: .zero, size: windowToAppearOn.frame.size)
		)
		contentViewController = NiEmptyViewController(
			viewFrame: windowToAppearOn.frame,
			contentController: myViewController
		)
		
		self.myViewController = myViewController

		hasShadow = false
		isOpaque = false
		isFloatingPanel = true
		backgroundColor = NSColor.clear
		hidesOnDeactivate = false
	}
	
	func removeSelf(){
		resignKey()
		
		//TODO: find out why hover states do not work in main window after homeview dissapeared.
		//place to fix is here

		orderOut(self)
		close()
	}
	
	override func keyDown(with event: NSEvent){
		if(event.keyCode == kVK_RightArrow){
			myViewController?.nextStep()
			return
		}
		
		if(event.keyCode == kVK_LeftArrow){
			myViewController?.prevStep()
			return
		}
		super.keyDown(with: event)
	}
}
