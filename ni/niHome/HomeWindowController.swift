//
//  HomeWindowController.swift
//  ni
//
//  Created by Patrick Lukas on 11/4/24.
//

import Cocoa
import SwiftUI

class HomeWindowController: NSWindowController {

	override func windowWillLoad() {
		print("This time for real")
	}
	
	override func loadWindow() {
//		self.window = NSWindow()
		self.window!.contentView = NSHostingView(rootView: HomeView())
	}
	
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
		let keyWindow = NSApplication.shared.keyWindow!
		keyWindow.addChildWindow(self.window!, ordered: .above)
    }

}
