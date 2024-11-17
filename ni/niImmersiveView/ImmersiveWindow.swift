//
//  ImmersiveWindow.swift
//  ni
//
//  Created by Patrick Lukas on 5/9/24.
//

import Cocoa
import Carbon.HIToolbox

class ImmersiveWindow: NSPanel{
	
	override var canBecomeKey: Bool {return true}
	override var canBecomeMain: Bool {return false}

	init(windowToAppearOn: NSWindow, urlReq: URLRequest){
		super.init(
			contentRect: windowToAppearOn.frame,
			styleMask: .borderless,
			backing: .buffered,
			defer: true
		)
		//set, as otherwise the desktop on the 2nd display will switch to a different desktop if an application is running fullscreen on that display
		collectionBehavior = NSWindow.CollectionBehavior.moveToActiveSpace
		titleVisibility = .hidden
		titlebarAppearsTransparent = true
		contentViewController = NiEmptyViewController(
			viewFrame: windowToAppearOn.frame,
			contentController: ImmersiveViewController(
				frame: NSRect(origin: .zero, size: windowToAppearOn.frame.size),
				urlReq: urlReq
			)
		)

		hasShadow = false
		isOpaque = false
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
}
