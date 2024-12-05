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
	
	private weak var spaceViewController: NiSpaceViewController?
	
	
	init(windowToAppearOn: NSWindow, spaceViewController: NiSpaceViewController){
		
		self.spaceViewController = spaceViewController
		
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
		UserSettings.updateValue(setting: .showedOnboarding, value: true)
		
		resignKey()
		orderOut(self)
		spaceViewController?.showHomeView(canBeDismissed: false)
		close()
	}
	
	override func keyDown(with event: NSEvent){
		guard !event.isARepeat else {return}
		if(event.keyCode == kVK_LeftArrow || event.keyCode == kVK_ANSI_A || event.keyCode == kVK_ANSI_J){
			myViewController?.prevStep()
			return
		}
		
		if(!event.modifierFlags.contains(.command)){
			myViewController?.nextStep()
			return
		}
		super.keyDown(with: event)
	}
	
	override func mouseDown(with event: NSEvent){
		if(!event.modifierFlags.contains(.command) && event.clickCount == 1){
			myViewController?.nextStep()
			return
		}
		super.mouseDown(with: event)
	}
	
	override func rightMouseDown(with event: NSEvent){
		if(!event.modifierFlags.contains(.command) && event.clickCount == 1){
			myViewController?.prevStep()
			return
		}
		super.rightMouseDown(with: event)
	}
}
